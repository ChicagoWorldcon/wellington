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

# TODO Extract to gem, move tests from Claim to this gem
# TODO Better tests, most of this is integration tested by Claim
module ActiveScopes
  def self.included(base)
    base.after_initialize :set_active_to

    base.validate :active_timestamps_ordered
    base.validates :active_from, presence: true

    # A transfer of ownership may happen at an instant, and from that moment the the new owner becomes the active party
    base.scope :active, ->() { active_at(Time.now) }
    base.scope :active_at, ->(moment) {
      where(
        %{
          #{base.table_name}.active_from <= ?    -- where active_from is before, inclusive
          AND (                                  -- and either
            #{base.table_name}.active_to IS NULL -- is open ended
            OR ? < #{base.table_name}.active_to  -- or is not yet closed, exclusive
          )
        },
        moment,
        moment,
      )
    }

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
end
