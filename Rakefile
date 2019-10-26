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

# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"
require "gem-licenses"

Rails.application.load_tasks
Gem::GemLicenses.install_tasks

# Migrations dump structure.sql after they're run
# Thanks to https://stackoverflow.com/a/18918552/81271
Rake::Task["db:migrate"].enhance do
  if ActiveRecord::Base.schema_format == :sql
    Rake::Task["db:structure:dump"].invoke
  end
end

Rake::Task["db:rollback"].enhance do
  if ActiveRecord::Base.schema_format == :sql
    Rake::Task["db:structure:dump"].invoke
  end
end
