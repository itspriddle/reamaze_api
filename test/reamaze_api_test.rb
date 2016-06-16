require "test_helper"

describe ReamazeAPI do
  describe "::config" do
    it "allows setting login, token, or brand globally" do
      ReamazeAPI.config do |c|
        c.brand = c.login = c.token = "something-else"
      end

      expect(ReamazeAPI.config.brand).must_equal "something-else"
      expect(ReamazeAPI.config.login).must_equal "something-else"
      expect(ReamazeAPI.config.token).must_equal "something-else"
    end
  end

  describe "::new" do
    before do
      ReamazeAPI.config do |c|
        c.brand = c.login = c.token = "secret"
      end
    end

    it "returns a ReamazeAPI::Client" do
      expect(ReamazeAPI.new).must_be_kind_of ReamazeAPI::Client
    end

    it "yields the Faraday::Connection if a block is given" do
      client = ReamazeAPI.new { |http| http.headers["foo"] = "bar" }

      expect(client.http.headers["foo"]).must_equal "bar"
    end
  end
end
