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

# HugoState abstracts date logic needed for checking if the hugos are open
class HugoState
  def has_nominations_opened?
    return false if closed?
    return false if has_voting_opened?

    utc($nomination_opens_at) <= now
  end

  def has_voting_opened?
    return false if closed?

    utc($voting_opens_at) <= now
  end

  def closed?
    open_time = utc($nomination_opens_at)..utc($hugo_closed_at)
    !open_time.cover?(now)
  end

  private

  def now
    utc(Time.now)
  end

  def utc(time)
    time.in_time_zone("UTC")
  end
end
