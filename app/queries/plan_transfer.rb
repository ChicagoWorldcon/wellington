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

# PlanTransfer is here to capture form information for a Support login to transfer a membership
class PlanTransfer
  FORM_FALSE_VALUES = ["0", false, nil].freeze

  include ActiveModel::Model
  include ActiveModel::Validations::ClassMethods

  attr_accessor :new_owner
  attr_accessor :reservation_id
  attr_accessor :copy_contact

  validates :reservation_id, presence: true
  validates :new_owner, presence: true, format: Devise.email_regexp

  def reservation
    @reservation ||= Reservation.find(reservation_id)
  end

  def from_user
    reservation.user
  end

  def to_user
    User.find_or_create_by_canonical_email(new_owner)
  end

  def contact
    reservation.active_claim.contact
  end

  # Workaround, forms post 0 or 1 strings for checkboxes
  def copy_contact?
    !copy_contact.in?(FORM_FALSE_VALUES)
  end
end
