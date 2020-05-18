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

  # Configure default model based on WORLDCON_CONTACT env var
  def self.worldcon_contact_model
    return "ConzealandContact" if ENV["WORLDCON_CONTACT"].nil?

    case ENV["WORLDCON_CONTACT"].downcase
    when "chicago"
      "ChicagoContact"
    when "conzealand"
      "ConzealandContact"
    when "dc"
      "DcContact"
    end
  end

  has_one :contact, class_name: worldcon_contact_model
end
