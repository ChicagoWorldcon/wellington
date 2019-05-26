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

# Purchase::PlanTransfer is here to capture information about a planned transfer
class Purchase::PlanTransfer
  include ActiveModel::Model
  include ActiveModel::Validations::ClassMethods

  attr_accessor :new_owner
  attr_accessor :purchase_id
  attr_accessor :copy_details

  validates :purchase_id, presence: true
  validates :new_owner, presence: true, format: Devise.email_regexp

  def purchase
    Purchase.find(purchase_id)
  end

  def from_user
    purchase.user
  end

  def to_user
    User.find_or_create_by(email: new_owner)
  end
end
