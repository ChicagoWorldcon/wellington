# Copyright 2020 Matthew B. Gray
# Copyright 2020 Steven Ensslen
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

# GlooSync sends user data to Gloo so they can log in for the virtual worldcon in 2020
class GlooSync
  include Sidekiq::Worker

  def perform(email)
    return unless ENV["GLOO_BASE_URL"].present?

    user = User.find_by!(email: email)
    GlooContact.new(user).save!
  end
end
