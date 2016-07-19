Minitest::Assertions.class_eval do
  # Asserts that a block calls the API with expected parameters.
  #
  # method - HTTP method (:get, :put, :post)
  # path   - API path (note that we prepend "/api/v1")
  # params - Optional request paramters
  #
  # Yields a ReamazeAPI::Client instance.
  # Raises MockExpectationError if the assertion fails.
  #
  # Example
  #
  #   assert_api_request :get, "/blah", { q: "query" } do |client|
  #     client.method
  #   end
  #
  # This works by mocking Faraday::Connection and verifying that the block
  # calls Faraday::Connection#run_request with expected parameters.
  def assert_api_request(method, path, params = {})
    body = Struct.new(:body, :success?).new({}, true)
    args = [method.to_sym, path, params, {}]

    http = Minitest::Mock.new
    http.expect :run_request, body, args

    client = ReamazeAPI.new
    client.instance_variable_set :@http, http

    yield client

    assert_mock http
  end

  # Asserts that a block calls the API and automatically fetches all pages.
  #
  # path - API path (eg: "/api/v1/messages")
  #
  # Yields a ReamazeAPI::Client instance.
  #
  # Example
  #
  #   assert_auto_pagination "/api/v1/conversations" do |client|
  #     client.conversations.all(auto_paginate: true)
  #   end
  #
  # This works by stubbing requests to the API to simulate pagination. The
  # stubbed API will return 5 resources with a page size of 2. The final
  # result is expected to include all 5 results from 3 separate API calls.
  def assert_auto_pagination(path)
    resource = path.split("/").last.to_sym
    request  = Faraday::Adapter::Test::Stubs.new

    request.get(path) do |env|
      output = { page_count: 3 }
      page   = JSON.parse(env.body).fetch("page", 1)

      output[resource] = [{ slug: "#{resource}-p#{page}-1" }]

      unless page == 3
        output[resource] << { slug: "#{resource}-p#{page}-2" }
      end

      [200, {}, output.to_json]
    end

    client = ReamazeAPI.new do |faraday|
      faraday.builder.swap(
        Faraday::Adapter::NetHttp,
        Faraday::Adapter::Test,
        request
      )
    end

    results = yield(client)

    collection = results[:payload][resource]

    expected = [
      { slug: "#{resource}-p1-1" },
      { slug: "#{resource}-p1-2" },
      { slug: "#{resource}-p2-1" },
      { slug: "#{resource}-p2-2" },
      { slug: "#{resource}-p3-1" }
    ]

    assert_equal expected, collection
  end
end

# Add some sugar for verifying HTTP requests.
#
# Verify GET, POST or PUT:
#
#   expect { |client| ... }.to_get  "/path", params
#   expect { |client| ... }.to_post "/path", params
#   expect { |client| ... }.to_put  "/path", params
#
# Raises MockExpectationError if the block does not try calling the API with
# the given paramters.
#
# Verify auto-pagination:
#
#   expect { |client| ... }.to_auto_paginate "/path"
Minitest::Expectations.class_eval do
  %i(to_get to_put to_post to_auto_paginate).each do |method|
    define_method method do |*args|
      Minitest::Expectation.new(self, Minitest::Spec.current).
        send(method, *args)
    end
  end
end

Minitest::Expectation.class_eval do
  %i(to_get to_put to_post).each do |method|
    define_method method do |*args|
      ctx.assert_api_request method[3..-1], *args do |client|
        target.call client if Proc === target
      end
    end
  end

  def to_auto_paginate(path)
    ctx.assert_auto_pagination(path) do |client|
      target.call client if Proc === target
    end
  end
end
