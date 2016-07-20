require "test_helper"

describe ReamazeAPI::Client do
  def build_client(&block)
    ReamazeAPI.new(**ReamazeAPI.config.to_h, &block)
  end

  describe "RaiseErrorMiddleware" do
    def stub_request(code:)
      client = ReamazeAPI::Testing.mock_client do |app|
        get "/api/v1/conversations" do |_|
          [code, {}, "{}"]
        end
      end

      client.conversations.all
    end

    after do
      ReamazeAPI.config.exceptions = false
    end

    it "returns error hash by default" do
      expect(stub_request(code: 400).fetch(:payload).fetch(:error)).
        must_equal "ReamazeAPI::ClientError"

      expect(stub_request(code: 403).fetch(:payload).fetch(:error)).
        must_equal "ReamazeAPI::Forbidden"

      expect(stub_request(code: 404).fetch(:payload).fetch(:error)).
        must_equal "ReamazeAPI::NotFound"

      expect(stub_request(code: 422).fetch(:payload).fetch(:error)).
        must_equal "ReamazeAPI::UnprocessableEntity"

      expect(stub_request(code: 429).fetch(:payload).fetch(:error)).
        must_equal "ReamazeAPI::TooManyRequests"

      expect(stub_request(code: 500).fetch(:payload).fetch(:error)).
        must_equal "ReamazeAPI::ServerError"
    end

    it "raises custom HTTP exceptions when configured" do
      ReamazeAPI.config.exceptions = true

      expect { stub_request(code: 400) }.must_raise ReamazeAPI::ClientError
      expect { stub_request(code: 403) }.must_raise ReamazeAPI::Forbidden
      expect { stub_request(code: 404) }.must_raise ReamazeAPI::NotFound
      expect { stub_request(code: 422) }.must_raise ReamazeAPI::UnprocessableEntity
      expect { stub_request(code: 429) }.must_raise ReamazeAPI::TooManyRequests
      expect { stub_request(code: 500) }.must_raise ReamazeAPI::ServerError
    end
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
