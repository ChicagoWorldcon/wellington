# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2019 AJ Esler
# Copyright 2020, 2021 Victoria Garcia
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

module ChargesHelper
  include ApplicationHelper

  MEMBERSHIP = CartItem::MEMBERSHIP
  MYSQL_MAX_FIELD_LENGTH = 255

  def stripe_config(prospective_purchase, prospective_amount = -1)
    our_desc_string = description_str_for_stripe(prospective_purchase)
    return {
        key: Rails.configuration.stripe[:publishable_key],
        description: our_desc_string,
        email: prospective_purchase.user.email,
        name: worldcon_public_name_spaceless,
        currency: $currency,
        prospective_amount: prospective_amount
    }.to_json
  end

  private

  def description_str_for_stripe(prospective_purchase)
    description_string = ""
    case
      when prospective_purchase.kind_of?(Reservation)
        description_string = "#{worldcon_public_name} #{prospective_purchase.membership.name} membership"

      when prospective_purchase.kind_of?(Cart)
        description_string = cart_contents_description(prospective_purchase)

      when prospective_purchase.kind_of?(CartItem)
        description_string = cart_item_description(prospective_purchase)
    else
      description_string = "#{worldcon_public_name} item"
    end

    if description_string.length > MYSQL_MAX_FIELD_LENGTH
      return description_string[0, MYSQL_MAX_FIELD_LENGTH]
    end

    description_string
  end

  def cart_contents_description(cart)
    description_string = CartContentsDescription.new(cart).describe_cart_contents
  end

  def cart_item_description(cart_item)
    beneficiary_info = cart_item.benefitable.present? ? "for #{cart_item.item_beneficiary_name}" : ""
    return "#{worldcon_public_name} #{cart_item.display_name} #{beneficiary_info}".strip!
  end
end
