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
require "csv"

RSpec.describe Export::MembershipCsv do
  subject(:query) { described_class.new }

  describe "#call" do
    subject(:call) { query.call }
    let(:csv) { CSV.parse(call) }

    it "is null without memberships" do
      expect(call).to be_nil
    end

    context "with memberships" do
      let!(:reservation) { create(:reservation, :with_claim_from_user, :with_order_against_membership) }

      describe "the headings" do
        subject(:headings) { csv.first }

        it { is_expected.to include(/first_name/i) }
        it { is_expected.to include(/country/i) }
      end

      describe "the rows" do
        subject(:rows) { csv[1..].join(",") }

        it { is_expected.to include(reservation.active_claim.detail.first_name) }
        it { is_expected.to include(reservation.membership_number.to_s) }
      end
    end
  end
end
