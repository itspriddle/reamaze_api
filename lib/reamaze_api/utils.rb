require "reamaze_api/utils/hash_keys"

module ReamazeAPI
  module Utils
    extend self

    # Public: Deep-symbolize keys in the given Hash.
    #
    # hash - a Hash instance
    #
    # Returns a Hash.
    def symbolize_hash(hash)
      HashKeys.deep_symbolize_keys(hash)
    end

    # Public: Hash used for error responses.
    #
    # exception - An Exception instance
    #
    # Returns a Hash.
    def error_hash(exception)
      {
        success: false,
        payload: {
          error:   exception.class.name,
          message: exception.message
        }
      }
    end
  end
end
