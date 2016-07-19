module ReamazeAPI
  class Conversation < Resource
    # Public: Retrieve conversations.
    #
    # params - Hash of parameters to pass to the API
    #
    # API Routes
    #
    #   GET /conversations
    #
    # See also: https://www.reamaze.com/api/get_conversations
    #
    # Returns a Hash.
    def all(params = {})
      paginate "/conversations", :conversations, params
    end

    # Public: Retrieve a specific conversation.
    #
    # slug - Conversation slug
    #
    # API Routes
    #
    #   GET /conversations/{slug}
    #
    # See also: https://www.reamaze.com/api/get_conversation
    #
    # Returns a Hash.
    def find(slug)
      get "/conversations/#{slug}"
    end

    # Public: Create a new conversation (on behalf of a customer).
    #
    # params - Hash of parameters to pass to the API
    #
    # API Routes
    #
    #   POST /conversations
    #
    # See also: https://www.reamaze.com/api/post_conversations
    #
    # Returns a Hash.
    def create(params)
      post "/conversations", params
    end
  end
end
