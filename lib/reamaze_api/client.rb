require "faraday_middleware"
require "uri"

module ReamazeAPI
  class Client
    # Reamaze's API doesn't always return JSON. If there's an error parsing
    # the response as JSON, just return the raw body.
    class Middleware < FaradayMiddleware::ParseJson
      define_parser do |body|
        begin
          JSON.parse(body) unless body.strip.empty?
        rescue
          body
        end
      end
    end

    Faraday::Response.register_middleware reamaze_api: lambda { Middleware }

    # Public: HTTP methods used by the API
    #
    # Returns an Array.
    HTTP_METHODS = %i(get put post)

    # Public: URL for Reamaze API.
    #
    # Returns a String.
    API_URL = "https://%{brand}.reamaze.com/api/v1".freeze

    # Public: Initialize a new Client instance.
    #
    # brand: Brand name (subdomain from your Reamaze URL)
    # login: Reamaze login
    # token: Reamaze API token
    #
    # Returns nothing.
    def initialize(brand:, login:, token:)
      @url = URI.parse(API_URL % { brand: brand })

      @http = Faraday.new(url: @url, ssl: { verify: true }) do |builder|
        builder.request    :json
        builder.response   :json
        builder.adapter    Faraday.default_adapter
        builder.basic_auth login, token
      end
    end

    # Public: Article resource.
    #
    # Returns an Article instance.
    def articles
      @articles ||= Article.new(self)
    end

    # Public: Channel resource.
    #
    # Returns a Channel instance.
    def channels
      @channels ||= Channel.new(self)
    end


    # Public: Contact resource.
    #
    # Returns a Contact instance.
    def contacts
      @contacts ||= Contact.new(self)
    end

    # Public: Conversation resource.
    #
    # Returns a Conversation instance.
    def conversations
      @conversations ||= Conversation.new(self)
    end

    # Public: Message resource.
    #
    # Returns a Message instance.
    def messages
      @messages ||= Message.new(self)
    end

    private

    # Private: Submits an HTTP request to the upstream API.
    #
    # method: HTTP method (eg: :get, :post)
    # path:   API path (without `/api/v1` prefix, eg: "/messages")
    # params: Hash of parameters to send with the request (default: {})
    #
    # Returns a Hash.
    def commit(method:, path:, params: {})
      path = "#{@url.path}#{path}"

      response = @http.run_request(method, path, params, {})

      Utils.symbolize_hash(success: response.success?, payload: response.body)
    rescue => e
      Utils.error_hash(e)
    end

    # Private: `get`, `put`, and `post` helper methods. These submit an HTTP
    # request to the upstream API.
    #
    # path:   API path (without `/api/v1` prefix, eg: "/messages")
    # params: Hash of parameters to send with the request (default: {})
    #
    # Returns a Hash.
    HTTP_METHODS.each do |method|
      define_method method do |path, params = {}|
        commit method: method, path: path, params: params
      end
    end
  end
end
