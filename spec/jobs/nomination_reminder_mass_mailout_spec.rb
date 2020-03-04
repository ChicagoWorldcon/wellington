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

      it "doesn't execute 20 minutes before the window" do
        $voting_opens_at = 3.days.from_now + 20.minutes
        expect(HugoMailer).to_not receive(:nominations_reminder_3_days_left)
        perform
      end

      it "doesn't execute 20 minutes after the window" do
        $voting_opens_at = 3.days.from_now - 20.minutes
        expect(HugoMailer).to_not receive(:nominations_reminder_3_days_left)
        perform
      end

      it "calls within the window" do
        $voting_opens_at = 3.days.from_now
        expect(HugoMailer).to receive_message_chain(:nominations_reminder_3_days_left, :deliver_later).and_return(true)
        perform
      end

      it "calls within the window across timezones" do
        $voting_opens_at = "2020-03-13T11:59:00-08:00".to_datetime
        three_days_from_welly = "2020-03-11T08:59:00+13:00".to_datetime
        Timecop.freeze(three_days_from_welly) do
          expect(HugoMailer).to receive_message_chain(:nominations_reminder_3_days_left, :deliver_later).and_return(true)
          perform
        end
      end

      it "does execute 20 minutes before the window when force is set" do
        $voting_opens_at = 10.days.from_now
        expect(HugoMailer).to receive_message_chain(:nominations_reminder_3_days_left, :deliver_later).and_return(true)
        job.perform(force: true)
      end
    end
  end
end
