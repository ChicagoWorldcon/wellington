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

RSpec.describe SendNominationSummaries, type: :job do
  let(:reservation) { create(:reservation, :with_order_against_membership, :with_claim_from_user) }

  describe "#perform" do
    subject(:perform) { described_class.new.perform }

    it "doesn't send to a user twice" do
      reservation.nominations << create(:nomination, created_at: 20.minutes.ago)

      expect(NominationMailer)
        .to receive_message_chain(:nomination_ballot, :deliver_now)
        .and_return(true)

      expect { described_class.new.perform }.to change { reservation.reload.ballot_last_mailed_at }

      expect(NominationMailer).to_not receive(:nomination_ballot)
      described_class.new.perform
    end

    context "after run" do
      after { perform }

      it "sends when a user nominated" do
        reservation.nominations << create(:nomination, created_at: 20.minutes.ago)
        expect(NominationMailer)
          .to receive_message_chain(:nomination_ballot, :deliver_now)
          .and_return(true)
      end

      it "doesn't include users who have already been mailed" do
        reservation.nominations << create(:nomination, created_at: 20.minutes.ago)
        reservation.update!(ballot_last_mailed_at: Time.now)
        expect(NominationMailer).to_not receive(:nomination_ballot)
      end

      it "ignores users who voted under 10 minutes ago" do
        reservation.nominations << create(:nomination, created_at: 5.minutes.ago)
        expect(NominationMailer).to_not receive(:nomination_ballot)
      end

      it "doesn't mail you if you're still updating the form" do
        reservation.nominations << create(:nomination, created_at: 5.minutes.ago)
        reservation.nominations << create(:nomination, created_at: 10.minutes.ago)
        reservation.nominations << create(:nomination, created_at: 15.minutes.ago)
        reservation.nominations << create(:nomination, created_at: 20.minutes.ago)
        expect(NominationMailer).to_not receive(:nomination_ballot)
      end

      it "emails people if we've not run the job in a while" do
        reservation.update!(ballot_last_mailed_at: 24.hours.ago)
        reservation.nominations << create(:nomination, created_at: 23.hours.ago)
        reservation.nominations << create(:nomination, created_at: 22.hours.ago)
        expect(NominationMailer)
          .to receive_message_chain(:nomination_ballot, :deliver_now)
          .and_return(true)
      end
    end
  end
end
