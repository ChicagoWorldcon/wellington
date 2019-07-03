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

# PlanC
class PlanCredit
  include ActiveModel::Model
  include ActiveModel::Validations::ClassMethods

  attr_accessor :amount # whole dollars, or pounds, or euros

  validates :amount, presence: true, numericality: { greater_than: 0 }

  # Convert amount to cents so we can store it with the Money gem
  def money
    Money.new(amount.to_f * 100)
  end
end
