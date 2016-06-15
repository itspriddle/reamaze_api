module ReamazeAPI
  class Article < Resource
    # Public: Retrieves KB articles.
    #
    # params - Hash of parameters to pass to the API
    #
    # API Routes
    #
    #   GET /articles
    #   GET /topics/{slug}/articles
    #
    # See also: https://www.reamaze.com/api/get_articles
    #
    # Returns a Hash.
    def all(params = {})
      params = Utils.symbolize_hash(params)

      get articles_path(params.delete(:topic))
    end

    # Public: Retrieves a specific KB article.
    #
    # slug - Article slug
    #
    # API Routes
    #
    #   GET /articles/{slug}
    #
    # See also: https://www.reamaze.com/api/get_article
    #
    # Returns a Hash.
    def find(slug)
      get "/articles/#{slug}"
    end

    # Public: Create a new KB article.
    #
    # params - Hash of parameters to pass to the API
    #
    # API Routes
    #
    #   POST /articles (no topic)
    #   POST /topics/{slug}/articles
    #
    # See also: https://www.reamaze.com/api/post_article
    #
    # Returns a Hash.
    def create(params)
      params = Utils.symbolize_hash(params)

      post articles_path(params.delete(:topic)), params
    end

    # Public: Update an existing KB article.
    #
    # slug   - Article slug
    # params - Hash of parameters to pass to the API
    #
    # API Routes
    #
    #   PUT /articles/{slug}
    #
    # See also: https://www.reamaze.com/api/put_article
    #
    # Returns a Hash.
    def update(slug, params)
      put "/articles/#{slug}", params
    end

    private

    # Private: Articles API path. If a topic slug is supplied the returned
    # path is prefixed with "/topic/#{topic}".
    #
    # topic_slug - The topic slug
    #
    # Returns a String.
    def articles_path(topic_slug = nil)
      if topic_slug
        "/topics/#{topic_slug}/articles"
      else
        "/articles"
      end
    end
  end
end
