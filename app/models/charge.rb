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

class Charge < ApplicationRecord
  FAILED = "failed"
  SUCCESSFUL = "successful"

  belongs_to :user
  belongs_to :purchase

  validates :comment, presence: true
  validates :cost, presence: true
  validates :purchase, presence: true
  validates :state, inclusion: {in: [FAILED, SUCCESSFUL]}
  validates :stripe_id, presence: true
  validates :user, presence: true

  scope :failed, ->() { where(state: FAILED) }
  scope :successful, ->() { where(state: SUCCESSFUL) }
end
