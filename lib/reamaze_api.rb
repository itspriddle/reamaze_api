# frozen_string_literal: true

require "reamaze_api/version"
require "reamaze_api/utils"
require "reamaze_api/error"
require "reamaze_api/client"
require "reamaze_api/resource"
require "reamaze_api/article"
require "reamaze_api/channel"
require "reamaze_api/contact"
require "reamaze_api/conversation"
require "reamaze_api/message"

module ReamazeAPI
  # Public: Configuration class
  Config = Struct.new(:brand, :login, :token, :exceptions)

  # Public: Optional default configuration used to authenticate with the
  # Reamaze API.
  #
  # Yields the Config instance if a block is given.
  #
  # Returns a Config instance.
  def self.config
    @config ||= Config.new
    yield @config if block_given?
    @config
  end

  # Public: Initializes a new API Client instance.
  #
  # **credentials - Credentials used with the Reamaze API (optional)
  #                 :brand - Brand name (subdomain from your Reamaze URL)
  #                 :login - Reamaze login
  #                 :token - Reamaze API token
  # block         - Optional block that yields a Faraday::Connection instance
  #                 (for customizing middleware, headers, etc)
  #
  # The credentials passed to the API can be configured globally via
  # `ReamazeAPI.config` or passed to this method. Credentials passed directly
  # to this method take precedence over those configured globally.
  #
  # Raises ArgumentError if a brand, login or token cannot be found.
  #
  # Returns a ReamazeAPI::Client instance.
  def self.new(**credentials, &block)
    params = {
      brand: credentials.fetch(:brand) { config.brand },
      login: credentials.fetch(:login) { config.login },
      token: credentials.fetch(:token) { config.token },
    }

    Client.new(**params, &block)
  end
end
