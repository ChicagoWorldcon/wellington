# frozen_string_literal: true

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

RSpec.describe Claim, type: :model do
  let(:user) { create(:user) }
  let(:reservation) { create(:reservation) }

  describe "#valid?" do
    context "when called without active_from" do
      subject(:claim) { Claim.create(user: user, reservation: reservation) }

      it { is_expected.to be_valid }

      it "sets active_from automatically" do
        expect(claim.active_from).to_not be_nil
      end

      it "doesn't set active_to" do
        expect(claim.active_to).to be_nil
      end
    end

    context "when called with active_from" do
      let(:sample_time) { 1.week.ago }

      subject(:claim) { Claim.create(user: user, reservation: reservation, active_from: sample_time) }

      it { is_expected.to be_valid }

      it "doesn't override active_from" do
        expect(claim.active_from).to eq sample_time
        expect { claim.save! }.to_not change { claim.active_from }
      end
    end

    context "when called with active_from and active_to" do
      let(:now) { Time.now }
      let(:last_week) { Time.now - 1.week }

      it "is invalid when dates aren't ordered" do
        claim = Claim.new(active_from: now, active_to: last_week, user: user, reservation: reservation)
        expect(claim).to_not be_valid
        expect(claim.errors.messages.keys).to_not include(:active_from)
        expect(claim.errors.messages.keys).to include(:active_to)
      end
    end
  end

  describe "#active_at" do
    context "with open ended #active_to" do
      let(:start) { 1.week.ago }
      let!(:current_claim) { Claim.create!(user: user, reservation: reservation, active_from: start) }

      it "doesn't set active_to" do
        expect(current_claim.active_to).to be_nil
      end

      it "isn't active before the start time" do
        expect(Claim.active_at(start - 1.second)).to_not include(current_claim)
      end

      it "becomes active at start time" do
        expect(Claim.active_at(start)).to include(current_claim)
      end

      it "is active after the start time" do
        expect(Claim.active_at(start + 1.second)).to include(current_claim)
      end
    end

    describe "#active_at" do
      let(:start) { 1.week.ago }
      let(:finish) { start + 3.days }
      let!(:closed_claim) { Claim.create!(user: user, reservation: reservation, active_from: start, active_to: finish) }

      subject(:scope) { Claim.active_at(time) }

      context "just before start of claim" do
        let(:time) { start - 1.second }
        it { is_expected.to_not include(closed_claim) }
      end

      context "at start of claim" do
        let(:time) { start }
        it { is_expected.to include(closed_claim) }
      end

      context "just before end of claim" do
        let(:time) { finish - 1.second }
        it { is_expected.to include(closed_claim) }
      end

      context "at the time the claim finishes" do
        let(:time) { finish }
        it { is_expected.to_not include(closed_claim) }
      end
    end
  end

  describe "factory" do
    subject(:model) do
      create(:claim,
        :with_reservation,
        :with_user,
        :with_conzealand_contact,
        :with_chicago_contact,
      )
    end

    it { is_expected.to be_valid }

    it "references different contacts" do
      expect(model.conzealand_contact).to be_valid
      expect(model.chicago_contact).to be_valid
    end
  end

  context "with multiple claims" do
    let(:existing_claim) { create(:claim, :with_reservation, :with_user, active_from: 1.week.ago) }
    let(:new_user) { create(:user) }
    let(:transferred_at) { 1.minute.ago }

    it "lets a user have multiple claims" do
      new_claim = build(:claim, :with_reservation, user: existing_claim.user)
      expect(new_claim).to be_valid
    end

    it "doen't let multiple users claim the same reservation" do
      new_claim = build(:claim, :with_user, reservation: existing_claim.reservation)
      expect(new_claim).to_not be_valid
    end

    it "allows other inactive claims on the same reservation" do
      new_claim = build(:claim, :with_user, reservation: existing_claim.reservation)
      existing_claim.update!(active_to: transferred_at)
      new_claim.active_from = transferred_at
      expect(existing_claim).to be_valid
    end
  end

  # If this is failing
  # And CoNZealand is no longer running
  # Please feel free to backspace this entire block
  context "after #sync_with_glue called" do
    after do
      # it's an after_commit hook, so executes after save
      create(:claim, :with_user, :with_reservation)
    end

    it "dosn't call GlueSync outside of conzealand" do
      Rails.configuration.contact_model = "dc"
      ENV["GLUE_BASE_URL"] = "https://api.thefantasy.network/v1"
      expect(GlueSync).to_not receive(:perform_async)
    end

    it "doesn't call GlueSync when not configured" do
      Rails.configuration.contact_model = "conzealand"
      ENV["GLUE_BASE_URL"] = nil
      expect(GlueSync).to_not receive(:perform_async)
    end

    it "calls when confgured in conzealand" do
      Rails.configuration.contact_model = "conzealand"
      ENV["GLUE_BASE_URL"] = "https://api.thefantasy.network/v1"
      expect(GlueSync).to receive(:perform_async)
    end
  end
end
