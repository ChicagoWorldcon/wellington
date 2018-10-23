# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
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

copy_pasta_keys = ENV.select { |variable, set_as| set_as.match(/copypasta/) }.keys
if copy_pasta_keys.any?
  puts "Badness detected, don't copy paste things. Please check the README and set these:"
  puts copy_pasta_keys.to_sentence
  exit 1
end
