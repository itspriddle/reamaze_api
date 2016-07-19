require "forwardable"

module ReamazeAPI
  class Resource
    extend Forwardable

    # Delegate HTTP actions back to the given Client.
    def_delegators :@client, :paginate, *Client::HTTP_METHODS

    # Public: Initialize a new Resource instance. API resources should inherit
    # from this class.
    #
    # client - ReamazeAPI::Client instance.
    #
    # Returns nothing.
    def initialize(client)
      @client = client
    end
  end
end
