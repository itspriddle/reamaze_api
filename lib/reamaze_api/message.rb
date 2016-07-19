module ReamazeAPI
  class Message < Resource
    # Public: Retrieves messages.
    #
    # params - Hash of parameters (those not listed below are passed directly
    #          to the API):
    #          :conversation_slug - Optional conversation slug
    #
    # API Routes
    #
    #   GET /messages
    #   GET /conversations/{slug}/messages
    #
    # See also: https://www.reamaze.com/api/get_messages
    #
    # Returns a Hash.
    def all(params = {})
      params = Utils.symbolize_hash(params)
      url    = message_path(params.delete(:conversation_slug))

      paginate url, :messages, params
    end

    # Public: Create a new message under the given conversation.
    #
    # params - Hash of parameters (those not listed below are passed directly
    #          to the API):
    #          :conversation_slug - Required conversation slug
    #
    # API Routes
    #
    #   POST /conversations/{slug}/messages
    #
    # See also: https://www.reamaze.com/api/post_messages
    #
    # Returns a Hash.
    def create(params)
      params = Utils.symbolize_hash(params)
      slug   = params.fetch(:conversation_slug)

      params.delete :conversation_slug

      post message_path(slug), params
    rescue KeyError => e
      Utils.error_hash(e)
    end

    private

    # Private: Messages API path. If a conversation slug is supplied the
    # returned path is prefixed with "/conversations/#{slug}".
    #
    # conversation_slug - The conversation slug
    #
    # Returns a String.
    def message_path(conversation_slug = nil)
      if conversation_slug
        "/conversations/#{conversation_slug}/messages"
      else
        "/messages"
      end
    end
  end
end
