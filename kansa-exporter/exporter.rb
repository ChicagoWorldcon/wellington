#!/usr/bin/env ruby

# frozen_string_literal: true

# Copyright 2018 Andrew Esler
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

require "rubygems"
require "bundler/setup"
require "active_record"
require "pry"

# Import ruby classes
project_root = File.dirname(File.absolute_path(__FILE__))
%w(models services).each do |type|
  Dir.glob(project_root + "/app/#{type}/*.rb").each { |f| require f }
end

# Set up active record connection
if !ENV["DATABASE_URL"].nil?
  ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
else
  connection_details = YAML::load(File.open("config/database.yml"))
  ActiveRecord::Base.establish_connection(connection_details)
end

if __FILE__ == $0
  puts ExportPeople.new.call
end
