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

# Claim represents a User holding a Membership through a Reservation
# ChicagoContact, DcContact and ConzealandContact represent details of the user who currently hold that membership
# Configure what model you're using through the env variable WORLDCON_CONTACT
# A new Claim is created when ApplyTransfer is called, marking the new claim as 'active' by setting properties on it
# Looking at the history of a Claim helps if you're considering refunding someone as it's no longer held by the same person
class Claim < ApplicationRecord
  include ActiveScopes
  include ThemeConcern

  belongs_to :user
  belongs_to :reservation

  # Most of these will be nil, depending on the configuration
  has_one :conzealand_contact
  has_one :chicago_contact
  has_one :dc_contact

  validates :reservation, uniqueness: {
    conditions: -> { active } # There can't be other active claims against the same reservation
  }, if: :active?

  def transferable?
    active_to.nil?
  end

  # Configure the model strategy depending on configuration.
  def self.contact_strategy
    theme_contact_class
  end

  has_one :contact, class_name: contact_strategy.to_s
end
