require "test_helper"

describe ReamazeAPI::Channel do
  it "gets channels with #all" do
    expect { |client| client.channels.all }.
      to_get "/api/v1/channels"

    expect { |client| client.channels.all(q: "search") }.
      to_get "/api/v1/channels", q: "search"
  end

  it "auto-paginates channels with #all(auto_paginate: true)" do
    expect { |client| client.channels.all(auto_paginate: true) }.
      to_auto_paginate "/api/v1/channels"
  end

  it "gets a single channel with #find" do
    expect { |client| client.channels.find("ID") }.
      to_get "/api/v1/channels/ID"
  end
end
