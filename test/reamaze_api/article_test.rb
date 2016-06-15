require "test_helper"

describe ReamazeAPI::Article do
  it "gets articles with #all" do
    expect { |client| client.articles.all }.
      to_get "/api/v1/articles"

    expect { |client| client.articles.all(topic: "support") }.
      to_get "/api/v1/topics/support/articles"
  end

  it "gets a single article with #find" do
    expect { |client| client.articles.find("ID") }.
      to_get "/api/v1/articles/ID"
  end

  it "creates a new article with #create" do
    params = { some: "param" }

    expect { |client| client.articles.create(params) }.
      to_post "/api/v1/articles", params

    expect { |client| client.articles.create(topic: "support", **params) }.
      to_post "/api/v1/topics/support/articles", params
  end

  it "updates an existing article with #update" do
    params = { some: "param" }

    expect { |client| client.articles.update("ID", params) }.
      to_put "/api/v1/articles/ID", params
  end
end
