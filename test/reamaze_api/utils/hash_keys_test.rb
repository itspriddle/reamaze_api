require "test_helper"

describe ReamazeAPI::Utils::HashKeys do
  describe "::deep_symbolize_keys" do
    subject do
      ReamazeAPI::Utils::HashKeys.deep_symbolize_keys(
        "hi"   => "josh",
        "deep" => { "hash" => { "keys" => 1 } }
      )
    end

    it "deep symbolizes hash keys" do
      expect(subject).must_equal(
        hi:   "josh",
        deep: { hash: { keys: 1 } }
      )
    end
  end
end
