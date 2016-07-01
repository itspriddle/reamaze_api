require "test_helper"

describe ReamazeAPI::Utils do
  describe "#symbolize_hash" do
    subject do
      ReamazeAPI::Utils.symbolize_hash(
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

  describe "#error_hash" do
    subject do
      ReamazeAPI::Utils.error_hash(StandardError.new("You broke it!"))
    end

    it "returns an error hash" do
      expect(subject).must_equal(
        success: false,
        payload: {
          error:   "StandardError",
          message: "You broke it!"
        }
      )
    end
  end
end
