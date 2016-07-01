# ReamazeAPI

Ruby library for working with the [Reamaze API][].

[Reamaze API]: https://www.reamaze.com/api

## Installation

Add this line to your application's Gemfile:

```ruby
gem "reamaze_api"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install reamaze_api

## Usage

First initialize a new client instance:

```ruby
client = ReamazeAPI.new(
  brand: "brand",          # Your Reamaze subdomain
  login: "me@example.com", # Your Reamaze login
  token: "somehash"        # Your Reamaze API token
)
```

If you use a single brand in your application, you can configure these
globally:

```ruby
ReamazeAPI.config do |c|
  c.brand = "brand"          # Your Reamaze subdomain
  c.login = "me@example.com" # Your Reamaze login
  c.token = "somehash"       # Your Reamaze API token
end

client = ReamazeAPI.new # Authenticate with the defaults provided above
```

To work with a resource:

```ruby
client.articles.all
client.articles.create(params)

client.channels.all
client.channels.find(id)

client.contact.all
client.contact.create
client.contact.update

client.conversations.all
client.conversations.find
client.conversations.create

client.messages.all
client.messages.create
```

ReamazeAPI uses the [Faraday][] library for HTTP interactions, and by default,
Net::HTTP. To configure a different HTTP adapter you can set
`Faraday.default_adapter`:

```ruby
Faraday.default_adapter = :httpclient
```

If you need more customization for Faraday, for example, to add additional
middleware or change request headers, you can call `ReamazeAPI.new` with a
block:

```ruby
class MyCoolMiddleware < Faraday::Response::Middleware
end

Faraday::Response.register_middleware \
  my_cool_middleware: MyCoolMiddleware

client = ReamazeAPI.new do |http|
  http.response :my_cool_middleware
  http.headers["User-Agent"] = "My Reamaze Client"
end
```

[Faraday]: https://github.com/lostisland/faraday

### API Errors

By default, ReamazeAPI returns an error Hash for any API response with status
400-599. For example, the API returns a 404 if you provide an invalid brand
name:

```ruby
client = ReamazeAPI.new brand: "invalid"
client.articles.all
# {
#     :success => false,
#     :payload => {
#          :error => "ReamazeAPI::NotFound",
#        :message => "GET https://invalid.reamaze.com/api/v1/articles: 404"
#     }
# }
```

If you would rather raise exceptions:

```ruby
ReamazeAPI.config do |c|
  c.exceptions = true
end

client = ReamazeAPI.new brand: "invalid"
client.articles.all # raises
# ReamazeAPI::NotFound: GET https://invalid.reamaze.com/api/v1/articles: 404
#   ...backtrace
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `rake test` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/itspriddle/reamaze_api.

