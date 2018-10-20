# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
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

RSpec.describe Grant, type: :model do
  let(:user) { create(:user) }
  let(:membership) { create(:membership) }

  describe "#valid?" do
    context "when called without active_from" do
      subject(:grant) { Grant.create(user: user, membership: membership) }

      it { is_expected.to be_valid }

      it "sets active_from automatically" do
        expect(grant.active_from).to_not be_nil
      end

      it "doesn't set active_to" do
        expect(grant.active_to).to be_nil
      end
    end

    context "when called with active_from" do
      let(:sample_time) { 1.week.ago }

      subject(:grant) { Grant.create(user: user, membership: membership, active_from: sample_time) }

      it { is_expected.to be_valid }

      it "doesn't override active_from" do
        expect(grant.active_from).to eq sample_time
        expect { grant.save! }.to_not change { grant.active_from }
      end
    end

    context "when called with active_from and active_to" do
      let(:now) { Time.now }
      let(:last_week) { Time.now - 1.week }

      it "is invalid when dates aren't ordered" do
        grant = Grant.new(active_from: now, active_to: last_week, user: user, membership: membership)
        expect(grant).to_not be_valid
        expect(grant.errors.messages.keys).to_not include(:active_from)
        expect(grant.errors.messages.keys).to include(:active_to)
      end
    end
  end

  describe "#active_at" do
    context "with open ended #active_to" do
      let(:start) { 1.week.ago }
      let!(:current_grant) { Grant.create!(user: user, membership: membership, active_from: start) }

      it "doesn't set active_to" do
        expect(current_grant.active_to).to be_nil
      end

      it "isn't active before the start time" do
        expect(Grant.active_at(start - 1.second)).to_not include(current_grant)
      end

      it "becomes active at start time" do
        expect(Grant.active_at(start)).to include(current_grant)
      end

      it "is active after the start time" do
        expect(Grant.active_at(start + 1.second)).to include(current_grant)
      end
    end

    context "when grant is closed setting #active_to" do
      let(:start) { 1.week.ago }
      let(:finish) { start + 3.days }
      let!(:closed_grant) { Grant.create!(user: user, membership: membership, active_from: start, active_to: finish) }

      it "is active when it's within the time range" do
        expect(Grant.active_at(start)).to include(closed_grant)
        expect(Grant.active_at(finish)).to include(closed_grant)
      end

      it "is inactive outside of time range" do
        expect(Grant.active_at(start - 1.second)).to_not include(closed_grant)
        expect(Grant.active_at(finish + 1.second)).to_not include(closed_grant)
      end
    end
  end
end
