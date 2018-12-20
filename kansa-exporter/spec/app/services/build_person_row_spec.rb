# frozen_string_literal: true

# Copyright 2018 Andrew Esler
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

require "spec_helper"

RSpec.describe BuildPersonRow do
  let(:person) { build(:person) }

  subject(:service) { BuildPersonRow.new(person) }

  describe "#to_row" do
    context "with errors on the person" do
      context "missing a payment" do
        before do
          expect(service).to receive(:payment).and_return(nil)
        end

        it "raises an error" do
          expect { service.to_row }.to raise_error(BuildPersonRow::ExportError, /is missing a payment/)
        end
      end

      context "payment membership does not match persons" do
        let(:person) { build(:person, membership: "Adult") }
        let(:mismatching_payment) { build(:payment, type: "Child") }

        before do
          allow(service).to receive(:payment).and_return(mismatching_payment)
        end

        it "raises an error" do
          expect { service.to_row }.to raise_error(BuildPersonRow::ExportError, /payment does not match membership/)
        end
      end
    end

    context "with valid data" do
      let(:person) { build(:person, id: 421) }
      let(:payment) { build(:payment) }
      let(:bump_membership_number) { 100 }

      before do
        allow(service).to receive(:payment).and_return(payment)
      end

      it "exports the row" do
        expect(service.to_row).to match_array [
          person.legal_name,
          person.public_first_name,
          person.public_last_name,
          person.badge_name,
          person.badge_subtitle,
          person.city,
          person.state,
          person.country,
          person.email,
          "Imported from kansa. People##{person.id}",
          person.membership,
          payment.stripe_charge_id,
          payment.amount,
          "kansa payment##{payment.id} for #{payment.amount.to_f / 100}#{payment.currency.upcase} paid with token #{payment.stripe_token} for #{payment.type} (#{payment.category})",
          person.member_number + bump_membership_number,
        ]
      end
    end
  end
end
