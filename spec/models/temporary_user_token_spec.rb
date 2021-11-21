require "rails_helper"

RSpec.describe TemporaryUserToken, type: :model do
  subject(:some_token) { create(:temporary_user_token) }
  subject(:expired) { create(:expired_token) }
  subject(:clashing) { create(:temporary_user_token, shortcode: expired.shortcode) }

  describe("shortcode attribute") do
    it "is a 6-character hex string" do
      regexp = /^[a-fA-F0-9]{6}/
      expect(some_token.shortcode).to match regexp
    end

    it "is unique" do
      expect { create(:temporary_user_token, shortcode: some_token.shortcode) }
        .to raise_error(ActiveRecord::RecordInvalid)
    end

    it "can be repeated for expired codes" do
      puts("##> #{expired}")
      expect(clashing.shortcode).to eq(expired.shortcode)
    end
  end
end
