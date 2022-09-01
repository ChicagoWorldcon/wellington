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
    destinations = ReportRecipient.where(report: "nomination").pluck(:email_address)
    if destinations.empty?
      puts("No nomination report recipients; skipping")
      return
    end

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
      to: destinations
    )
  end

  def ranks_csv
    destinations = ReportRecipient.where(report: "rank").pluck(:email_address)
    if destinations.empty?
      puts("No ranks report recipients; skipping")
      return
    end

    command = Export::RankCsv.new
    csv = command.call
    return if csv.nil?

    date = Date.today.iso8601
    attachments["ranks-#{date}.csv"] = {
      mime_type: "text/csv",
      content: csv
    }

    @stats = command.stats
    mail(
      subject: "Ranks export #{date}",
      to: destinations
    )
  end

  def memberships_csv
    destinations = ReportRecipient.where(report: "membership").pluck(:email_address)
    if destinations.empty?
      puts("No membership report recipients; skipping")
      return
    end

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
      to: destinations
    )
  end

  def site_selection_csv
    destinations = ReportRecipient.where(report: "siteselection").pluck(:email_address)

    if destinations.empty?
      puts("No site selection recipients; skipping")
      return
    end

    csv = Export::TokenCsv.new.call
    return if csv.nil?

    date = Date.today.iso8601

    attachments["site-selection-#{date}.csv"] = {
      mime_type: "text/csv",
      content: csv
    }

    mail(
      subject: "Site Selection export #{date}",
      to: destinations
    )
  end

  def virtual_memberships_csv
    destinations = ReportRecipient.where(report: "virtual").pluck(:email_address)

    if destinations.empty?
      puts("No virtual report recipients; skipping")
      return
    end

    csv = Export::VirtualCsv.new.call
    return if csv.nil?

    date = Date.today.iso8601

    attachments["virtual-members-#{date}.csv"] = {
      mime_type: "text/csv",
      content: csv
    }

    mail(
      subject: "Virtual Members export #{date}",
      to: destinations
    )
  end

  private

  def border_styles
    %(
      border: 1px solid #333;
      padding: 5px 10px;
    )
  end
end
