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

require 'csv'

namespace :import do
  DEFAULT_KANSA_CSV = "kansa-export.csv"
  DEFAULT_PRESUPPORT_SRC = "CoNZealand master members list - combining PreSupports, Site Selection and at W76 Memberships V02 - Test Setup for Data Import to Membership System.csv"
  DEFAULT_DUBLIN_SRC = "unduplicated members-Table 1.csv"

  desc "Imports from conzealand Kansa spreadsheet export. Override file location by setting KANSA_SRC env var"
  task kansa: :environment do
    kansa_csv = File.open(ENV["KANSA_SRC"] || DEFAULT_KANSA_CSV)
    kansa_importer = Import::KansaMembers.new(File.open(kansa_csv), "Exported from Kansa")
    if !kansa_importer.call
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
      fallback_email: $member_services_email,
    )
    if !presupport_importer.call
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
    if !success
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

    importer = Import::ChicagoBidMembers.new(voters, members, payments, "Chicago Bid Import from #{dump_path} at #{as_at}")
    success = importer.call
    if ! success
      puts "Failed with errors:"
      importer.errors.each do |error|
        puts" :: #{error}"
      end
    end
  end
end
