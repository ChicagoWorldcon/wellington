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

namespace :check do
  desc "Iterate through all models, find invalid ones, print them for further investigation"
  task models: :environment do
    model_files = Rails.root.join("app/models/*.rb")
    Dir[model_files.to_s].each do |filename|
      klass = File.basename(filename, ".rb").camelize.constantize
      next unless klass.ancestors.include?(ActiveRecord::Base)
      next if klass.abstract_class?

      invalid_models = klass.all.reject(&:valid?)
      if invalid_models.count > 0
        puts "#{klass} has #{invalid_models.count} bad models, #{klass}.where(id: #{invalid_models.map(&:id)})"
      elsif klass.count == 0
        puts "#{klass} has no models"
      else
        puts "#{klass} has valid models"
      end
    end
  end
end
