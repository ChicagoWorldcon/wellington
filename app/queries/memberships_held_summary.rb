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

class MembershipsHeldSummary
  attr_reader :current_user

  def initialize(current_user)
    @current_user = current_user
  end

  def to_s
    grouped = memberships.group(:name).count
    printable = grouped.map { |name, count| "#{count} #{name.humanize}" }.sort

    if printable.none?
      ""
    elsif printable.last.starts_with?("1 ")
      "#{printable.to_sentence} Membership"
    else
      "#{printable.to_sentence} Memberships"
    end
  end

  private

  def memberships
    Membership.joins(:purchases).where(purchases: {id: current_user.purchases})
  end
end
