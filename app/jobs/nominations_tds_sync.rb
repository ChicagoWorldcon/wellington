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

# ExportNominationsJob syncs categories and nominations in batches with Dave's Microsoft SQL database
# Enabled by setting TDS_DATABASE in your env
# Runs on a schedule defined in config/sidekiq.yml
class NominationsTdsSync
  include Sidekiq::Worker

  def perform
    # Don't peform this job if TDS_DATABASE variable is not present
    return unless ENV["TDS_DATABASE"].present?

    Export::CategoriesToTds.new.call
    Export::NominationsToTds.new.call
  end
end
