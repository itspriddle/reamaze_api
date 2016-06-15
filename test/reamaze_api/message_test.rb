require "test_helper"

describe ReamazeAPI::Message do
  it "gets messages with #all" do
    params = { q: "search" }

    expect { |client| client.messages.all }.
      to_get "/api/v1/messages"

    expect { |client| client.messages.all(params) }.
      to_get "/api/v1/messages", params

    expect { |client| client.messages.all(conversation_slug: "ID") }.
      to_get "/api/v1/conversations/ID/messages"

    expect { |client| client.messages.all(params.merge(conversation_slug: "ID")) }.
      to_get "/api/v1/conversations/ID/messages", params
  end

  it "creates a new message with #create" do
    params = { some: "param" }

    expect { |client| client.messages.create(params.merge(conversation_slug: "ID")) }.
      to_post "/api/v1/conversations/ID/messages", params
  end

  it "return KeyError when #create is not supplied a :conversation_slug" do
    exception = KeyError.new("key not found: :conversation_slug")
    error     = ReamazeAPI::Utils.error_hash(exception)
    out       = ReamazeAPI.new.messages.create({})

    expect(out).must_equal error
  end
end
