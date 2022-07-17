#!/usr/bin/env ruby
# frozen_string_literal: true

require "passgen"
require "csv"

namespace :ops do
  desc "Add a new support user"
  task :add_support, [:email] => :environment do |_t, args|
    password = Passgen.generate
    email = args[:email] || abort("An email is required")
    Support.create(
      email: email,
      password: password
    )
    puts "Created <#{email}>"
    puts "Password: '#{password}'"
  end

  task :add_hugo_admin, [:email] => :environment do |_t, args|
    password = Passgen.generate
    email = args[:email] || abort("An email is required")
    Support.create!(
      email: email,
      password: password,
      hugo_admin: true
    )
    puts "Created <#{email}>"
    puts "Password: '#{password}'"
  end

  desc "Send a nominations-are-open email to all eligible members"
  task nomination_mailout: :environment do
    NominationsOpenMassMailoutJob.perform_later
  end

  desc "Send a nominations-are-open email to a single eligible member"
  task :nomination_single, [:email] => :environment do |_t, args|
    user = User.find_by(email: args[:email])
    if user.present?
      NominationsOpenNotificationJob.perform_later(user_id: user.id)
    else
      puts "No such user: #{args[:email]}"
      exit(1)
    end
  end

  desc "Disable a membership"
  task :disable_membership, %i[member_id reason] => :environment do |_t, args|
    member_id = args[:member_id] || abort("no member number")
    reason = args[:reason] || "no reason given"
    Reservation.transaction do
      reservation = Reservation.find_by(membership_number: member_id.to_i)
      reservation.update!(state: Reservation::DISABLED)
      reservation.user.notes.create!(content: "IT Disabled membership #{member_id} -- #{reason}")

      r = Reservation.find_by(membership_number: member_id.to_i)
      puts "#{r.membership_number}: #{r.state}"
      r.user.notes.each { |n| puts n.content }
    end
  end

  task :bulk_disable, [:disable_file] => :environment do |_t, args|
    members = CSV.table(args[:disable_file])
    ActiveRecord::Base.transaction do
      curr_disabled = Reservation.disabled.count
      members.each do |m|
        membership_number = m[:membership_number]
        reason = m[:Note]
        reservation = Reservation.find_by(membership_number: membership_number.to_i)
        claim_name = reservation.active_claim.contact.first_name

        if reservation.state == Reservation::DISABLED
          puts "Skipping '#{claim_name}' membership #{membership_number}: not enabled anyway"
          next
        end

        reservation.update!(state: Reservation::DISABLED)
        reservation.user.notes.create!(
          content: "IT Disabled membership #{membership_number} for '#{claim_name} -- #{reason}"
        )
      end
      new_disabled = Reservation.disabled.count
      puts "Disabled #{new_disabled - curr_disabled} records"
    end
  end

  task :load_tokens, %i[token_file election_name] => :environment do |_t, args|
    token_file = args[:token_file] || abort("A token file is required")
    election_name = args[:election_name] || abort("An election name is required")
    tokens = CSV.read(token_file) || abort("Unable to read #{token_file}")
    created_at = updated_at = Time.now
    election_tokens = tokens.map do |tok|
      { election: election_name, voter_id: tok[0], token: tok[1], created_at: created_at, updated_at: updated_at }
    end

    SiteSelectionToken.insert_all(election_tokens)
  end
end
