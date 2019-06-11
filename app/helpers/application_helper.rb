# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2019 AJ Esler
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

module ApplicationHelper
  DEFUALT_NAV_CLASSES = %w(navbar navbar-dark shadow-sm).freeze

  # The root page has an expanded menu
  def navigation_classes
    if request.path == root_path
      DEFUALT_NAV_CLASSES
    else
      DEFUALT_NAV_CLASSES + %w(bg-dark)
    end.join(" ")
  end

  def upgrade_link(reservation, offer:)
    link_to(
      # link text, based on offer's #to_s
      offer.link_text,
      # link with params, enough to perform the upgrade action
      edit_upgrade_path(reservation, { offer: offer.to_s }),
      # confirmation, check with our user
      data: { confirm: offer.confirm_text }
    )
  end

  # Currency conversion, might be superseeded by #58
  def present_currency_worth_for(reservation)
    total_cents = reservation.charges.successful.sum(:amount)
    return nil if total_cents <= 0

    formatted_money = number_to_currency(total_cents / 100)
    "#{formatted_money} NZD"
  end
end
