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

RSpec.describe SendMembershipReports, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform }

    around do |test|
      original_value = $membership_reports_email
      test.run
      $membership_reports_email = original_value
    end

    it "calls to mailer when $membership_reports_email set" do
      $membership_reports_email = "harry@potter.universe"
      expect(ReportMailer).to receive_message_chain(:memberships_csv, :deliver_now).and_return(true)
      perform
    end
  end
end
