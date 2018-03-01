# frozen_string_literal: true

module ReamazeAPI
  class Channel < Resource
    # Public: Retrieves channels.
    #
    # params - Hash of parameters to pass to the API
    #
    # API Routes
    #
    #   GET /channels
    #
    # See also: https://www.reamaze.com/api/get_channels
    #
    # Returns a Hash.
    def all(params = {})
      paginate "/channels", :channels, params
    end

    # Public: Retrieve a specific channel.
    #
    # slug - Channel slug
    #
    # API Routes
    #
    #   GET /channels/{slug}
    #
    # See also: https://www.reamaze.com/api/get_channel
    #
    # Returns a Hash.
    def find(slug)
      get "/channels/#{slug}"
    end
  end
end
