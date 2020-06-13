# Copyright 2020 Matthew B. Gray
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "rails_helper"

RSpec.describe GlooContact do
  let(:supporting) { create(:membership, :supporting) }
  let(:adult) { create(:membership, :adult) }
  let(:user) { create(:user) }

  describe "#call" do
    subject(:call) { described_class.new(user).call }

    it { is_expected.to be_kind_of(Hash) }

    it "has the user's id" do
      expect(call[:id]).to eq(user.id.to_s)
      expect(call[:id]).to be_kind_of(String) # always be careful with types of IDs
    end

    it "doesn't give the user a name" do
      expect(call[:name]).to be_blank
      expect(call[:display_name]).to be_blank
    end

    it "has no roles" do
      expect(call[:roles]).to be_empty
    end

    it "doesn't add roles for supporting memberships" do
      create(:reservation, membership: supporting, user: user)
      expect(call[:roles]).to be_empty
    end

    it "doesn't add roles for unpaid attending memberships" do
      create(:reservation, :instalment, membership: adult, user: user)
      expect(call[:roles]).to be_empty
    end

    context "with paid attending membership" do
      let!(:reservation) { create(:reservation, membership: adult, user: user) }

      it "includes the video role" do
        expect(call[:roles]).to include("video")
      end

      it "leaves the names blank when contact information is missing" do
        expect(call[:name]).to be_blank
      end

      # This is a CNZ only requirement. Get in touch if you need this integration
      it "uses the conzealand_contact details on the member" do
        conzealand_contact = create(:conzealand_contact, claim: reservation.active_claim)
        expect(call[:name]).to eq(conzealand_contact.to_s)
        expect(call[:display_name]).to eq(conzealand_contact.badge_display)
      end

      # This happens when we integrate data from other systems so we just do our best
      it "leaves the names blank when record is invalid" do
        conzealand_contact = create(:conzealand_contact, claim: reservation.active_claim)
        conzealand_contact.update_column(:country, nil)
        expect(conzealand_contact.reload).to_not be_valid
        expect(call[:name]).to eq(conzealand_contact.to_s)
        expect(call[:display_name]).to eq(conzealand_contact.badge_display)
      end
    end

    context "with rights from other systems" do
      subject(:call) { described_class.new(user, remote_user: from_gloo).call }

      let(:from_gloo) do
        {
          id: user.id.to_s,
          email: user.email,
          name: "Harry Potter",
          display_name: "Catalonian Fireball slayer",
          roles: ["moderator"],
        }
      end

      it "keeps the remote roles" do
        expect(call[:roles]).to include("moderator")
      end

      it "doesn't add video without attending membership" do
        expect(call[:roles]).to_not include("video")
      end

      it "adds video when attending membership present" do
        create(:reservation, membership: adult, user: user)
        expect(call[:roles]).to include("video")
      end
    end

    it "cycles memberships on transfer" do
      last_minute_decision = create(:reservation, user: user, created_at: 1.day.ago, membership: adult)
      create(:conzealand_contact, first_name: "last minute decision", claim: last_minute_decision.active_claim)

      early_bird_reservation = create(:reservation, user: user, created_at: 365.days.ago, membership: adult)
      create(:conzealand_contact, first_name: "early bird price", claim: early_bird_reservation.active_claim)

      result = GlooContact.new(user).call
      expect(result[:display_name]).to match(/early bird price/)
      expect(result[:roles]).to include("video")

      ApplyTransfer.new(early_bird_reservation, from: user, to: create(:user), audit_by: "agile squirrel").call
      result = GlooContact.new(user.reload).call
      expect(result[:display_name]).to match(/last minute decision/)
      expect(result[:roles]).to include("video")

      ApplyTransfer.new(last_minute_decision, from: user, to: create(:user), audit_by: "agile squirrel").call
      result = GlooContact.new(user.reload).call
      expect(result[:display_name]).to be_empty
      expect(result[:roles]).to be_empty
    end
  end
end
