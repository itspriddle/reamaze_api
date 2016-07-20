Minitest::Assertions.class_eval do
  # Asserts that a block calls the API with expected parameters.
  #
  # method - HTTP method (:get, :put, :post)
  # path   - API path
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
end

Minitest::Expectation.class_eval do
  # Verify HTTP requests.
  #
  # path   - API path
  # params - Optional request paramters
  #
  # Examples
  #
  #   expect { |client| ... }.to_get  "/path", params
  #   expect { |client| ... }.to_post "/path", params
  #   expect { |client| ... }.to_put  "/path", params
  #
  # Raises MockExpectationError if the block does not try calling the API with
  # the given paramters.
  #
  # Returns true if the assertion is true.
  %i(to_get to_put to_post).each do |method|
    define_method method do |*args|
      ctx.assert_api_request method[3..-1], *args do |client|
        target.call client if Proc === target
      end
    end
  end
end
