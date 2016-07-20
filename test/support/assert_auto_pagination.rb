Minitest::Assertions.class_eval do
  # Asserts that a block calls the API and automatically fetches all pages.
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
  # This works by stubbing requests to the API to simulate pagination. The
  # stubbed API will return 5 resources with a page size of 2. The final
  # result is expected to include all 5 results from 3 separate API calls.
  def assert_auto_pagination(path)
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
