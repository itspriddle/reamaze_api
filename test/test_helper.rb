require "reamaze_api"
require "minitest/autorun"
require_relative "support/assert_api_request"
require_relative "support/assert_auto_pagination"
require_relative "support/mock_client"

ReamazeAPI.config do |c|
  c.brand = "foo"
  c.login = "foo"
  c.token = "blah"
end
