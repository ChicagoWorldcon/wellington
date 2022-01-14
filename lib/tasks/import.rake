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

require "csv"

namespace :import do
  DEFAULT_KANSA_CSV = "kansa-export.csv"
  DEFAULT_PRESUPPORT_SRC = "CoNZealand master members list - combining PreSupports, Site Selection and at W76 Memberships V02 - Test Setup for Data Import to Membership System.csv"
  DEFAULT_DUBLIN_SRC = "unduplicated members-Table 1.csv"

  desc "Imports from conzealand Kansa spreadsheet export. Override file location by setting KANSA_SRC env var"
  task kansa: :environment do
    kansa_csv = File.open(ENV["KANSA_SRC"] || DEFAULT_KANSA_CSV)
    kansa_importer = Import::KansaMembers.new(File.open(kansa_csv), "Exported from Kansa")
    unless kansa_importer.call
      puts "Kansa members failed to import with these errors..."
      puts kansa_importer.errors.each { |e| puts e }
    end
  end

  desc "Imports from conzealand presupporters spreadsheet. Override file location by setting PRESUPPORT_SRC env var"
  task presupporters: :environment do
    presupport_csv = File.open(ENV["PRESUPPORT_SRC"] || DEFAULT_PRESUPPORT_SRC)
    presupport_importer = Import::Presupporters.new(
      presupport_csv,
      description: "CoNZealand master members list, sheet 2",
      fallback_email: $member_services_email
    )
    unless presupport_importer.call
      puts "Presupporters failed to import with these errors..."
      presupport_importer.errors.each { |e| puts e }
    end
  end

  desc "Imports from unduplicated Dublin members provided by Tammy"
  task dublin: :environment do
    as_at = Time.now.iso8601
    dublin_csv = File.open(ENV["DUBLIN_SRC"] || DEFAULT_PRESUPPORT_SRC)
    file_name = dublin_csv.path.split("/").last
    importer = Import::DublinMembers.new(dublin_csv, "Dublin Import from #{file_name} at #{as_at}")
    success = importer.call
    unless success
      puts "Failed with errros"
      importer.errors.each do |error|
        puts " * #{error}"
      end
    end
  end

  desc "Imports chicago bid data"
  task chicago: :environment do
    as_at = Time.now.iso8601

    dump_path = ENV["CHICAGO_BID_DUMP_DIR"] || Dir.pwd
    voters = CSV.table("#{dump_path}/voters.csv").map(&:to_h)
    members = CSV.table("#{dump_path}/members.csv").map(&:to_h)
    payments = CSV.table("#{dump_path}/payments.csv").map(&:to_h)

    importer = Import::ChicagoBidMembers.new(voters, members, payments,
                                             "Chicago Bid Import from #{dump_path} at #{as_at}")
    success = importer.call
    unless success
      puts "Failed with errors:"
      importer.errors.each do |error|
        puts " :: #{error}"
      end
    end
  end

  desc "Imports member data for nominating rights"
  task :nominators, [:member_csv] => :environment do |_t, args|
    members = CSV.table(args[:member_csv])
    Membership.transaction do
      membership = Membership.where(
        name: "nominating",
        description: "Hugo Award Nominating membership",
        can_vote: false,
        can_attend: false,
        price_cents: 0,
        price_currency: "USD",
        can_nominate: true,
        can_site_select: false,
        dob_required: false,
        display_name: "Discon III Member",
        private_membership_option: true
      ).first_or_create
    end

    membership = Membership.active.find_by(name: "nominating")

    def login_mail(record)
      record[:first_chicon_email_plus_discon_email] || record[:second_chicon_email_plus_discon_email]
    end

    def contact_email(record)
      record[:second_chicon_email_plus_discon_email] || login_email(record)
    end

    # first, create all of our users.
    User.transaction do
      current_emails = User.all.map { |u| u.email }
      as_at = Time.now
      start_user_count = User.count
      User.insert_all(members.map { |nm| login_mail(nm) }
                        .compact
                        .uniq
                        .reject { |login| current_emails.include? login }
                        .map do |login|
                        {
                          email: login,
                          created_at: as_at,
                          updated_at: as_at
                        }
                      end)
      end_user_count = User.count
      puts "Created #{end_user_count - start_user_count} users"
    end

    start_claim_count = Claim.active.count
    members.each_slice(100) do |member_slice|
      ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
        member_slice.each do |nm|
          login = login_mail(nm)
          unless login.present?
            puts "No data found in row: #{nm}; skipping"
            break
          end

          # first, only create the user if it doesn't already exist
          user = User.find_by(email: login)

          unless user.present?
            puts "Unable to find a user or create one for email='#{login}'"
            next
          end

          unless user.id
            puts "Malformed user with email='#{login}': '#{user}"
            next
          end

          # we know we're creating a new contact.
          contact = ChicagoContact.create!(
            email: contact_email(nm),
            title: nm[:title],
            first_name: nm[:first_name],
            last_name: nm[:last_name],
            preferred_first_name: nm[:preferred_first_name],
            preferred_last_name: nm[:preferred_last_name],
            badge_title: nm[:badge_title],
            badge_subtitle: nm[:badge_subtitle],
            address_line_1: nm[:address_line_1],
            address_line_2: nm[:address_line_2],
            city: nm[:city],
            province: nm[:province],
            postal: nm[:postal],
            country: nm[:country],
            publication_format: "send_me_email"
          )
          as_at = Time.now
          membership_number = Reservation.maximum(:membership_number) + 1
          reservation = Reservation.create!(
            membership_number: membership_number,
            state: (membership.price.zero? ? Reservation::PAID : Reservation::INSTALMENT)
          )
          Order.create!(active_from: as_at, membership: membership, reservation: reservation)
          begin
            Claim.create!(active_from: as_at, user: user, reservation: reservation)
          rescue ActiveRecord::NotNullViolation => e
            require "pry"
            binding.pry
            puts(e.message)
            raise
          end

          contact.claim = reservation.active_claim
          contact.save!

          note_details = {
            source: nm[:convention],
            discon_membership_number: nm[:membership_number],
            chicon_membership_number: membership_number
          }
          user.notes.create!(
            content: <<~CONTENT
              Discon Import, from #{nm[:convention]}
              Discon Membership number: #{nm[:membership_number]}
              Chicon Membership number: #{membership_number}
              #+begin_src json
              #{note_details.to_json}
              #+end_src
            CONTENT
          )
        end
        end_claim_count = Claim.active.count

        puts "Created #{end_claim_count - start_claim_count} claims (reservations)"
      end
    end
  end
end
