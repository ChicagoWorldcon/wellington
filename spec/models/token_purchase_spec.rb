require "rails_helper"

RSpec.describe TokenPurchase, type: :model do
  before do
    @reservation = create(:reservation)
  end

  context "when there are no tokens" do
    it "should fail to purchase a token" do
      expect { TokenPurchase.for_election!(@reservation, "Election") }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context "when tokens are available" do
    let(:existing_token) do
      create(:site_selection_token)
    end

    subject do
      TokenPurchase.for_election!(@reservation, existing_token.election)
    end

    before do
      existing_token.save!
    end

    it "should purchase the next unclaimed site selection token" do
      expect(subject.site_selection_token).to eq(existing_token)
    end

    it "should save a purchase" do
      expect { subject }.to change {
                              TokenPurchase.count
                            }.by(1)
    end

    it "should leave fewer available tokens" do
      expect { subject }.to change { SiteSelectionToken.unclaimed.count }.by(-1)
    end
  end

  context "when there are no tokens left for this election" do
    before do
      @token = create(:site_selection_token)
      @purchase = TokenPurchase.for_election!(@reservation, "Election")
    end

    it "should fail to purchase the next unclaimed site selection token" do
      expect do
        TokenPurchase.for_election!(@reservation, "Election")
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should leave the same number available tokens" do
      expect do
        TokenPurchase.for_election!(@reservation, "Election")
      rescue ActiveRecord::RecordInvalid
        # nothing
      end.not_to change { SiteSelectionToken.unclaimed.count }
    end
  end
end
