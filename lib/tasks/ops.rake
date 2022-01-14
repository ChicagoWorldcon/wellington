#!/usr/bin/env ruby
# frozen_string_literal: true

require "passgen"

namespace :ops do
  desc "Add a new support user"
  task :add_support, [:email] => :environment do |_t, args|
    password = Passgen.generate
    email = args[:email] || abort("An email is required")
    Support.create(
      email: email,
      password: password,
      confirmed_at: Time.now
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
end
