module ReamazeAPI
  class Contact < Resource
    # Public: Retrieve contacts.
    #
    # params - Hash of parameters to pass to the API
    #
    # API Routes
    #
    #   GET /contacts
    #
    # See also: https://www.reamaze.com/api/get_contacts
    #
    # Returns a Hash.
    def all(params = {})
      get "/contacts", params
    end

    # Public: Create a new contact.
    #
    # params - Hash of parameters to pass to the API
    #
    # API Routes
    #
    #   POST /contacts
    #
    # See also: https://www.reamaze.com/api/post_contacts
    #
    # Returns a Hash.
    def create(params)
      post "/contacts", params
    end

    # Public: Update an existing contact.
    #
    # slug   - Contact slug (email)
    # params - Hash of parameters to pass to the API
    #
    # API Routes
    #
    #   PUT /contacts/{slug}
    #
    # See also: https://www.reamaze.com/api/put_contacts
    #
    # Returns a Hash.
    def update(slug, params)
      put "/contacts/#{slug}", params
    end
  end
end
