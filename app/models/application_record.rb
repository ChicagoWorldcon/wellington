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

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  protected

  # CoNZealand only thing, this'll do nothing unless configured
  def gloo_sync
    return if Rails.env.test?                                 # guard against trigger background jobs from specs
    return unless ENV["GLOO_BASE_URL"].present?               # guard against sync unless configured
    return unless Claim.contact_strategy == ConzealandContact # guard against sync unless conzealand specifically
    return unless gloo_lookup_user.present?                   # guard against sync if we can't associate a user with this model

    GlooSync.perform_async(gloo_lookup_user.email)
  end
end
