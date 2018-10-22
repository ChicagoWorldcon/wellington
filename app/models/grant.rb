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

class Grant < ApplicationRecord
  belongs_to :user
  belongs_to :membership

  validates :membership, presence: true
  validates :user, presence: true

  after_initialize :set_active_to
  validates :active_from, presence: true
  validate :active_timestamps_ordered

  scope :active, ->() { active_at(Time.now) }
  scope :active_at, ->(at) { where("active_from <= ? AND (active_to IS NULL OR ? <= active_to)", at, at) }

  def transferable?
    active_to.nil?
  end

  private

  def set_active_to
    self[:active_from] ||= Time.now
  end

  def active_timestamps_ordered
    return if self.active_from.nil? || self.active_to.nil?
    return if self.active_from <= active_to
    errors.add(:active_to, "cannot be before active_from")
  end
end
