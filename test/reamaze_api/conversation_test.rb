require "test_helper"

describe ReamazeAPI::Conversation do
  it "gets conversations with #all" do
    expect { |client| client.conversations.all }.
      to_get "/api/v1/conversations"

    expect { |client| client.conversations.all(q: "search") }.
      to_get "/api/v1/conversations", q: "search"
  end

  it "gets a single conversation with #find" do
    expect { |client| client.conversations.find("ID") }.
      to_get "/api/v1/conversations/ID"
  end

  it "auto-paginates conversations with #all(auto_paginate: true)" do
    expect { |client| client.conversations.all(auto_paginate: true) }.
      to_auto_paginate "/api/v1/conversations"
  end

  it "creates a new conversation with #create" do
    params = { some: "param" }

    expect { |client| client.conversations.create(params) }.
      to_post "/api/v1/conversations", params
  end
end
