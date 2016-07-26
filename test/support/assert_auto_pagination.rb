Minitest::Assertions.class_eval do
  # Public: Asserts that the given block calls the API and auto-paginates the
  # results. Two scenarios are tested. When all API requests are valid the
  # block should return resources from all pages. When any API request is
  # invalid (eg: 404) the block should return an error hash.
  #
  # path - API path (eg: "/api/v1/messages")
  #
  # Yields a ReamazeAPI::Client instance.
  #
  # Example
  #
  #   assert_auto_pagination "/api/v1/conversations" do |client|
  #     client.conversations.all(auto_paginate: true)
  #   end
  #
  # This works by stubbing requests to the API to simulate pagination.
  # Successful auto-pagination must return all resources for a set of pages
  # and must return an error hash if the API returns an error. See
  # `assert_auto_pagination_success` and `assert_auto_pagination_error`
  # methods below for more info.
  #
  # Returns true if auto-pagination works successfully.
  def assert_auto_pagination(path, &block)
    assert_auto_pagination_success path, &block
    assert_auto_pagination_error   path, &block
  end

  private

  # Private: Asserts that a block calls the API and automatically fetches all
  # pages.
  #
  # path - API path (eg: "/api/v1/messages")
  #
  # Yields a ReamazeAPI::Client instance.
  #
  # This works by stubbing requests to the API to simulate pagination. The
  # stubbed API will return 5 resources with a page size of 2. The final
  # result is expected to include all 5 results from 3 separate API calls.
  #
  # Returns true if output contains results from all pages.
  def assert_auto_pagination_success(path)
    resource = path.split("/").last.to_sym

    client = ReamazeAPI::Testing.mock_client do
      get(path) do |env|
        output = { page_count: 3 }
        page   = JSON.parse(env.body).fetch("page", 1)

        output[resource] = [{ slug: "#{resource}-p#{page}-1" }]

        unless page == 3
          output[resource] << { slug: "#{resource}-p#{page}-2" }
        end

        [200, {}, output.to_json]
      end
    end

    results = yield(client)

    collection = results[:payload][resource]

    expected = [
      { slug: "#{resource}-p1-1" },
      { slug: "#{resource}-p1-2" },
      { slug: "#{resource}-p2-1" },
      { slug: "#{resource}-p2-2" },
      { slug: "#{resource}-p3-1" }
    ]

    assert_equal expected, collection
  end

  # Private: Asserts that a block calls the API and returns an error.
  #
  # path - API path (eg: "/api/v1/messages")
  #
  # Yields a ReamazeAPI::Client instance.
  #
  # This works by stubbing requests to the API to simulate pagination with a
  # 404 error on page 2. The final result is expected to include *only* the
  # error.
  #
  # Returns true if output is an error response.
  def assert_auto_pagination_error(path)
    resource = path.split("/").last.to_sym

    client = ReamazeAPI::Testing.mock_client do
      get(path) do |env|
        output = { page_count: 3 }
        page   = JSON.parse(env.body).fetch("page", 1)

        if page == 1
          code             = 200
          output[resource] = [{ slug: "#{resource}-p#{page}-1" }]
          output = output.to_json
        else
          code   = 404
          output = "404 not found"
        end

        [code, {}, output]
      end
    end

    results = yield(client)

    error = ReamazeAPI::Error.from_response(
      method: :get,
      url:    client.http.build_url(path),
      status: 404,
      body:   "404 not found"
    )

    expected = {
      success: false,
      payload: {
        error:   error.class.name,
        message: error.to_s
      }
    }

    assert_equal expected, results
  end
end

Minitest::Expectation.class_eval do
  # Verify auto-pagination
  #
  # path - API path
  #
  # Examples
  #
  #   expect { |client| ... }.to_auto_paginate "/path"
  #
  # Returns true if the assertion is true.
  def to_auto_paginate(path)
    ctx.assert_auto_pagination(path) do |client|
      target.call client if Proc === target
    end
  end
end
