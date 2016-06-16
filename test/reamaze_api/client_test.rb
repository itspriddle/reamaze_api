require "test_helper"

describe ReamazeAPI::Client do
  def build_client(&block)
    ReamazeAPI::Client.new(**ReamazeAPI.config.to_h, &block)
  end

  describe "::new" do
    it "yields the Faraday::Connection if a block is given" do
      client = build_client { |http| http.headers["foo"] = "bar" }

      expect(client.http.headers["foo"]).must_equal "bar"
    end
  end

  describe "#http" do
    it "returns a Faraday::Client instance" do
      expect(build_client.http).must_be_kind_of Faraday::Connection
    end
  end

  describe "#articles" do
    it "returns an Article" do
      expect(build_client.articles).must_be_kind_of ReamazeAPI::Article
    end
  end

  describe "#channels" do
    it "returns a Channel instance" do
      expect(build_client.channels).must_be_kind_of ReamazeAPI::Channel
    end
  end

  describe "#contacts" do
    it "returns a Contact instance" do
      expect(build_client.contacts).must_be_kind_of ReamazeAPI::Contact
    end
  end

  describe "#conversations" do
    it "returns a Conversation instance" do
      expect(build_client.conversations).must_be_kind_of ReamazeAPI::Conversation
    end
  end

  describe "#messages" do
    it "returns a Message instance" do
      expect(build_client.messages).must_be_kind_of ReamazeAPI::Message
    end
  end
end
