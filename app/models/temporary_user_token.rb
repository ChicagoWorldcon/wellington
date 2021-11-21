# frozen_string_literal: true

# Copyright 2021 Chris Rose
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

# Temporary user tokens are a way for us to provide a shortcode login that still
# relies on JWT to securely encode the user information. This is the same token
# that we email to the user.
class TemporaryUserToken < ApplicationRecord
  default_scope do
    moment = Time.now
    where(%(
      #{quoted_table_name}.active_from <=?
      AND ? < #{quoted_table_name}.active_to
    ), moment, moment)
  end

  validates :token, presence: true

  # There can't be other active tokens with the same shortcode
  validate :unique_shortcode_in_scope

  # generate a shortcode for the user
  after_initialize :generate_shortcode!

  # set some default active scopes
  after_initialize :set_time_bounds!

  private

  def unique_shortcode_in_scope
    errors.add(:shortcode, "has already been taken") if self.class.exists?(shortcode: shortcode)
  end

  def set_time_bounds!
    return if active_to && active_from

    self[:active_from] = Time.now
    self[:active_to] = 10.minutes.from_now
  end

  def generate_shortcode!
    return if shortcode

    begin
      self.shortcode = SecureRandom.hex(3)
    end while self.class.exists?(shortcode: shortcode)
  end

  def to_s
    "#{token} | #{shortcode}: expires at #{active_to}"
  end
end
