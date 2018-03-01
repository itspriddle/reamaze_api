# frozen_string_literal: true

module ReamazeAPI
  # Encapsulates HTTP errors that may be returned by the Reamaze API. All API
  # errors inherit from this class.
  class Error < StandardError
    # Public: Create an exception from the given response.
    #
    # response - HTTP response (Faraday::Env)
    #
    # Returns a ReamazeAPI::Error or nil.
    def self.from_response(response)
      if klass = case response[:status].to_i
                 when 403
                   ReamazeAPI::Forbidden
                 when 404
                   ReamazeAPI::NotFound
                 when 422
                   ReamazeAPI::UnprocessableEntity
                 when 429
                   ReamazeAPI::TooManyRequests
                 when 400..499
                   ReamazeAPI::ClientError
                 when 500..599
                   ReamazeAPI::ServerError
                 end

        klass.new(response)
      end
    end

    # Public: Initialize a new ReamazeAPI::Error instance.
    #
    # response - HTTP response (Faraday::Env)
    #
    # Returns nothing.
    def initialize(response = nil)
      @response = response
      super(build_message)
    end

    private

    # Private: Error message to be displayed.
    #
    # Returns a String or nil.
    def build_message
      return if @response.nil?

      message = [].tap do |msg|
        msg << "#{@response[:method].to_s.upcase} "
        msg << "#{@response[:url]}: "
        msg << "#{@response[:status]}"
        msg << "\n\nBODY: #{@response[:body].inspect}" if @response[:body]
      end

      message.join("")
    end
  end

  # Raised on HTTP 400-499
  class ClientError < Error; end

  # Raised on HTTP 403 (bad username/password)
  class Forbidden < ClientError; end

  # Raised on HTTP 404 (eg: bad brand or API URL)
  class NotFound < ClientError; end

  # Raised on HTTP 422 (eg: missing params in a POST)
  class UnprocessableEntity < ClientError; end

  # Raised on HTTP 429 (API rate limit exceeded)
  class TooManyRequests < ClientError; end

  # Raised on HTTP 500-599 (error on the Reamaze API server itself)
  class ServerError < Error; end
end
