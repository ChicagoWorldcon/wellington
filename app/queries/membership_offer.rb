# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2019 Jen Zajac (jenofdoom)
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

class MembershipOffer
  attr_reader :membership

  def self.options
    Membership.active.order_by_price.map do |membership|
      MembershipOffer.new(membership)
    end
  end

  def initialize(membership)
    @membership = membership
  end

  def to_s
    if membership.description.present?
      "#{membership} - #{membership.description} (#{formatted_price})"
    else
      "#{membership} (#{formatted_price})"
    end
  end

  # TODO Extract to i18n
  def formatted_price
    if membership.price > 0
      "$%.2f #{$currency}" % (membership.price * 1.0 / 100)
    else
      "free"
    end
  end

  def name
    "#{membership}"
  end

  def description
    if membership.description.present?
      "#{membership.description}"
    else
      ""
    end
  end
end
