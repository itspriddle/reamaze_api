require "test_helper"

describe ReamazeAPI::Contact do
  it "gets contacts with #all" do
    expect { |client| client.contacts.all }.
      to_get "/api/v1/contacts"

    expect { |client| client.contacts.all(q: "search") }.
      to_get "/api/v1/contacts", q: "search"
  end

  it "auto-paginates contacts with #all(auto_paginate: true)" do
    expect { |client| client.contacts.all(auto_paginate: true) }.
      to_auto_paginate "/api/v1/contacts"
  end

  it "creates a new contact with #create" do
    params = { some: "param" }

    expect { |client| client.contacts.create(params) }.
      to_post "/api/v1/contacts", params
  end

  it "updates an existing contact with #update" do
    params = { some: "param" }

    expect { |client| client.contacts.update("ID", params) }.
      to_put "/api/v1/contacts/ID", params
  end
end
