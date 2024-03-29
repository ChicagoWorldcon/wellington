# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
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

RSpec.describe ApplyCredit do
  let!(:adult_price) { Money.from_amount(400) }
  let!(:adult_membership) { create(:membership, :adult, price: adult_price) }
  let!(:reservation) do
    create(:reservation, :instalment, :with_claim_from_user,
      membership: adult_membership,
      instalment_paid: 0,
    )
  end
  let!(:amount) { adult_price - Money.from_amount(10) }
  let!(:audit_person) { "helper" }

  subject(:command) { described_class.new(reservation, amount, audit_by: audit_person) }

  describe "#call" do
    subject(:call) { command.call }

    it { is_expected.to be_truthy }

    it "creates a charge" do
      expect { call }.to change { Charge.count }.by(1)
      expect(Charge.last.amount).to eq amount
    end

    it "creates a note" do
      expect { call }.to change { Note.count }.by(1)
      expect(Note.last.content).to include audit_person
    end

    it "doesn't change status from instalment" do
      expect { call }
        .to_not change { reservation.reload.state }
        .from(Reservation::INSTALMENT)
    end

    it "doesn't log the current membership as the last fully paid" do
      expect { call }
      .to_not change { reservation.reload.last_fully_paid_membership }
      .from(nil)
    end

    it "delegates to ChargeDescription" do
      test_comment = "testing account credit"
      expect(ChargeDescription)
        .to receive_message_chain(:new, :for_users)
        .and_return(test_comment)

      call
      expect(Charge.last.comment).to eq test_comment
    end

    context "when credit amount covers membership" do
      let(:amount) { adult_price }

      it "flips state over to paid" do
        expect { call }
          .to change { reservation.reload.state }
          .from(Reservation::INSTALMENT)
          .to(Reservation::PAID)
      end

      it "logs the current membership as the last fully paid" do
        expect { call }
          .to change { reservation.reload.last_fully_paid_membership }
          .from(nil)
          .to(reservation.membership)
      end
    end
  end
end
