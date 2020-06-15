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

class Claim < ApplicationRecord
  include ActiveScopes
  include ThemeConcern

  # Configure the way we save user details based on configuration for this con
  def self.contact_strategy
    theme_contact_class
  end

  belongs_to :user
  belongs_to :reservation

  # Most of these will be nil, depending on the configuration
  has_one :conzealand_contact
  has_one :chicago_contact
  has_one :dc_contact
  has_one :contact, class_name: theme_contact_class.to_s

  # There can't be other active claims against the same reservation
  validates :reservation, uniqueness: { conditions: -> { active } }, if: :active?

  def transferable?
    active_to.nil?
  end

  # Sync when claim changes as transfer will cause your rights or default name to change
  after_commit :gloo_sync
  def gloo_lookup_user
    user
  end
end
