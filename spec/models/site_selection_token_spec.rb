require "rails_helper"

RSpec.describe SiteSelectionToken, type: :model do
  subject(:model) { create(:site_selection_token) }
  it { is_expected.to be_valid }

  it "should not allow a duplicate in the same election" do
    new_one = subject.dup
    new_one.token = "doesn't matter, it's new"
    expect(new_one.valid?).to be_falsey
  end

  it "should be unclaimed" do
    subject.save!
    expect(SiteSelectionToken.unclaimed.count).to be(1)
  end

  context "when purchased" do
    subject(:model) { create(:site_selection_token, :purchased) }

    it "should be claimed" do
      subject.save!
      expect(SiteSelectionToken.unclaimed.count).to be(0)
    end
  end
end
