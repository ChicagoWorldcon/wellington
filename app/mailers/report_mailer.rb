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

class ReportMailer < ApplicationMailer
  include ApplicationHelper
  default from: $maintainer_email

  helper_method :border_styles

  def nominations_csv
    return if $nomination_reports_email.nil?

    command = Export::NominationCsv.new
    csv = command.call
    return if csv.nil?

    date = Date.today.iso8601

    attachments["nominations-#{date}.csv"] = {
      mime_type: "text/csv",
      content: csv
    }

    @stats = command.stats

    mail(
      subject: "Nominations export #{date}",
      to: $nomination_reports_email,
    )
  end

  def memberships_csv
    return if $membership_reports_email.nil?

    command = Export::MembershipCsv.new
    csv = command.call
    return if csv.nil?

    date = Date.today.iso8601

    attachments["memberships-#{date}.csv"] = {
      mime_type: "text/csv",
      content: csv
    }

    @stats = Reservation.joins(:membership).group("memberships.name", "reservations.state").count

    mail(
      subject: "Memberships export #{date}",
      to: $membership_reports_email,
    )
  end

  private

  def border_styles
    %{
      border: 1px solid #333;
      padding: 5px 10px;
    }
  end

end
