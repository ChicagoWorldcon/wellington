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

RSpec.describe NominationReminderMassMailout, type: :job do
  subject(:job) { described_class.new }

  # Reset dates after tests run
  # pasta from config/initializers/hugo.rb
  after do
    SetHugoGlobals.new.call
  end

  describe "#perform" do
    subject(:perform) { job.perform }

    before do # open nominations
      $nomination_opens_at = 1.second.ago
      $hugo_closed_at = 5.days.from_now
    end

    context "with users" do
      before { create(:user, :with_reservation) }

      it "doesn't execute an hour before the window" do
        $voting_opens_at = 3.days.from_now + 1.hour
        expect(HugoMailer).to_not receive(:nominations_reminder_3_days_left)
        perform
      end

      it "doesn't execute an hour after the window" do
        $voting_opens_at = 3.days.from_now - 1.hour
        expect(HugoMailer).to_not receive(:nominations_reminder_3_days_left)
        perform
      end

      it "calls within the window" do
        $voting_opens_at = 3.days.from_now
        expect(HugoMailer).to receive_message_chain(:nominations_reminder_3_days_left, :deliver_later)
        perform
      end
    end
  end
end
