# frozen_string_literal: true

# Copyright 2020 Steven Ensslen
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

# RanksReminder sends reminders to users who can vote to tell them "not long to go!"
class RankReminderMassMailout
  include Sidekiq::Worker

  def perform(force: false)
    return unless force || within_send_window?

    last_time = Time.now
    users_to_remind = User.eager_load(reservations: :membership).merge(Membership.can_vote)

    users_to_remind.find_each.with_index do |user, i|
      RankMailer.ranks_reminder_3_days_left(email: user.email).deliver_later

      # Throttle to 10 per second so we don't saturate production
      if i % 10 == 0
        duration = Time.now - last_time
        backoff = 1.second - duration
        sleep(backoff) if backoff > 0
        last_time = Time.now
      end
    end
  end

  private

  # 3 days from now, but lets keep it close the 72 hours to go mark
  def within_send_window?
    three_days_to_go = utc($hugo_closed_at - 3.days)
    now = utc(DateTime.now)
    upper_bound = three_days_to_go + 15.minutes
    lower_bound = three_days_to_go - 15.minutes
    now.in?(lower_bound...upper_bound)
  end

  def utc(datetime)
    datetime.in_time_zone("UTC")
  end
end
