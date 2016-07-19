require "faraday_middleware"
require "uri"

module ReamazeAPI
  class Client
    # Raises a ReamazeAPI::Error for any HTTP response code 400-599.
    class RaiseErrorMiddleware < Faraday::Response::Middleware
      private

      # Private: Raises a ReamazeAPI::Error for any HTTP response code
      # 400-599.
      #
      # response - HTTP response (Faraday::Env)
      #
      # Returns nothing.
      def on_complete(response)
        if error = ReamazeAPI::Error.from_response(response)
          raise error
        end
      end
    end

    # Public: HTTP methods used by the API
    #
    # Returns an Array.
    HTTP_METHODS = %i(get put post)

    # Public: URL for Reamaze API.
    #
    # Returns a String.
    API_URL = "https://%{brand}.reamaze.com/api/v1".freeze

    # Public: HTTP adapter used for API requests.
    #
    # Returns a Faraday::Connection.
    attr_reader :http

    # Public: Initialize a new Client instance.
    #
    # brand: Brand name (subdomain from your Reamaze URL)
    # login: Reamaze login
    # token: Reamaze API token
    #
    # Yields a Faraday::Connection if a block is given.
    #
    # Returns nothing.
    def initialize(brand:, login:, token:)
      @url = URI.parse(API_URL % { brand: brand })

      @http = Faraday.new(url: @url, ssl: { verify: true }) do |builder|
        builder.request    :json
        builder.response   :json
        builder.use        RaiseErrorMiddleware
        builder.adapter    Faraday.default_adapter
        builder.basic_auth login, token

        yield builder if block_given?
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
    # Raises a ReamazeAPI::Error for any HTTP response code 400-599 unless
    # `ReamazeAPI.config.exceptions` is false.
    #
    # Returns a Hash.
    def commit(method:, path:, params: {})
      path = "#{@url.path}#{path}"

      response = @http.run_request(method, path, params, {})

      Utils.symbolize_hash(success: response.success?, payload: response.body)
    rescue ReamazeAPI::Error => e
      raise if ReamazeAPI.config.exceptions

      Utils.error_hash(e)
    end

    # Private: Performs a GET request on the given path/resource. If results
    # are more than one page, each additional page is fetched and added to the
    # payload. If any page returns an error response, that response is
    # immediately returned and no further requests are performed.
    #
    # NOTE: Beware of API rate limiting when using this method with large
    # datasets.
    #
    # path     - API path (without `/api/v1` prefix, eg: "/messages")
    # resource - ReamazeAPI resource name (eg: `:messages`)
    # params   - Hash of parameters to send with the request (default: {})
    #
    # Returns a Hash.
    def paginate(path, resource, params = {})
      params        = Utils.symbolize_hash(params)
      auto_paginate = params.delete(:auto_paginate)
      output        = get(path, params)
      page          = params.fetch(:page, 1)
      success       = output[:success]
      payload       = output[:payload]
      page_count    = payload[:page_count]

      if success && auto_paginate && page_count && page_count > page
        more = paginate(path, resource, params.merge(
          page:          page.next,
          auto_paginate: true
        ))

        if more[:success] && more[:payload]
          payload[resource].concat more[:payload][resource]
        else
          output[:success] = false
          output[:payload] = more[:payload]
        end
      end

      output
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
