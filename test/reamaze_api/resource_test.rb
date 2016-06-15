require "test_helper"

describe ReamazeAPI::Resource do
  it "delegates HTTP methods to the given client" do
    client   = Minitest::Mock.new
    resource = ReamazeAPI::Resource.new(client)

    %i(get put post).each do |method|
      client.expect method, ""
      resource.send method
    end

    assert_mock client
  end
end
