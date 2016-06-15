require "reamaze_api"
require "minitest/autorun"
require_relative "support/assert_api_response"

ReamazeAPI.config do |c|
  c.brand = "foo"
  c.login = "foo"
  c.token = "blah"
end
