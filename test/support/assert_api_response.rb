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
end

# Add some sugar for verifying HTTP requests:
#
#   expect { |client| ... }.to_get "/path", params
#
# Raises MockExpectationError if the block does not try calling the API with
# the given paramters.
Minitest::Expectations.class_eval do
  %i(to_get to_put to_post).each do |method|
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
end
