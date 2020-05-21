#!/usr/bin/env ruby

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

# We rely on exit codes for CI, but when there's a security vulnerability,
# yarn exits with a fialure code which fails CI. However this is only bad
# iff we can patch it. If there's no patch then we can't action it.
#
# So this script fails CI if there are security problems with patches
# Or if the security problem has been around for longer than a month

require "date"
require "json"

PATCH_DEADLINE = 180 # days to respond, double what project 0 gives

Classifier = Struct.new(:report) do
  def should_action?
    patch_available? || upstream_not_responding?
  end

  private

  # According to yarn's cli.js
  # the string 'No patch available' is printed when patched versions are '<0.0.0'
  # verify with:
  # grep -r 'No patch available' /usr/lib/node_modules/yarn/
  def patch_available?
    patched_versions = report.dig("data", "advisory", "patched_versions")
    patched_versions != "<0.0.0" # whitelist. If anything other than <0.0.0, there's a patch to apply.
  end

  # They've got a month to get a patch out before we start failing CI
  # At this point we should look for an alternative library
  def upstream_not_responding?
    created_at = report.dig("data", "advisory", "created")
    patch_age_in_days = (DateTime.now - DateTime.parse(created_at)).to_i
    patch_age_in_days > PATCH_DEADLINE
  end
end

audit_json = `yarn audit --json`.lines.map { |line| JSON.parse(line) }
reports = audit_json[0..-2]
_summary = audit_json.last # We don't use this, labelling it anyway

reports_to_action = reports.map { |r| Classifier.new(r) }.select(&:should_action?)

if reports.any?
  puts `yarn audit` # human friendly printout
end

summary = "#{reports_to_action.count}/#{reports.count} reports found that need actioning"

if reports_to_action.any?
  puts "FAIL - #{summary}"
  exit 1
else
  puts "PASS - #{summary}"
  exit 0
end
