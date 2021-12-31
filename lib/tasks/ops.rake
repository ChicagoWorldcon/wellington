#!/usr/bin/env ruby
# frozen_string_literal: true

require "passgen"

namespace :ops do
  desc "Add a new support user"
  task add_support: :environment do
    password = Passgen.generate
    email = ENV["SUPPORT_EMAIL"]
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
end
