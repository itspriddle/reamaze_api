module ReamazeAPI
  module Testing
    # Public: Initializes a ReamazeAPI::Client instance using the Faraday test
    # adapter. The given block is used to stub API requests.
    #
    # block - A block to pass to a Faraday::Adapter::Test::Stubs instance
    #
    # Example
    #
    #   client = ReamazeAPI::Testing.mock_client do
    #     get "/api/v1/conversations" do |env|
    #       [200, {}, "{...}"]
    #     end
    #   end
    #
    #   client.conversations.all # hits the mock API
    #
    # Returns a ReamazeAPI::Client.
    def self.mock_client(&block)
      stubs = Faraday::Adapter::Test::Stubs.new

      stubs.instance_exec(&block)

      ReamazeAPI.new do |faraday|
        faraday.builder.swap(
          Faraday::Adapter::NetHttp,
          Faraday::Adapter::Test,
          stubs
        )
      end
    end
  end
end
