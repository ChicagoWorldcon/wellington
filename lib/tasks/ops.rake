#!/usr/bin/env ruby
require 'passgen'

namespace :ops do
  desc "Add a new support user"
  task :add_support => :environment do
    password = Passgen::generate
    email = ENV["SUPPORT_EMAIL"]
    Support.create(
      email: email,
      password: password,
      confirmed_at: Time.now,
    )
    puts "Created <#{email}>"
    puts "Password: '#{password}'"
  end
end
