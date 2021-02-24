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

  MEMBERSHIP = "membership"

  def stripe_config(prospective_purchase)
    our_desc_string = description_str_for_stripe(prospective_purchase)
    return {
        key: Rails.configuration.stripe[:publishable_key],
        description: our_desc_string,
        email: prospective_purchase.user.email,
        name: worldcon_public_name_spaceless,
        currency: $currency,
    }.to_json
  end

  private

  def description_str_for_stripe(prospective_purchase)
    description_string = ""
    if prospective_purchase.kind_of? Reservation
      description_string = "#{worldcon_public_name} #{prospective_purchase.membership.name} membership"
    elsif prospective_purchase.kind_of? Cart
      description_string = cart_contents_description(prospective_purchase)
    elsif prospective_purchase.kind_of? CartItem
      description_string = cart_item_description(prospective_purchase)
    else
      description_string = "#{worldcon_public_name} item"
    end

    return description_string
  end

  def cart_contents_description(cart)
    description_string = ""
    cart.cart_items.each do |i|
      if i.kind == MEMBERSHIP
        item_desc = "#{worldcon_public_name} #{i.item_display_name} membership for #{i.item_beneficiary_name}, "
      else
        item_desc = "#{worldcon_public_name} #{i.item_display_name}, "
      end
      description_string = description_string.concat(item_desc)
    end
    description_string.chomp!(", ")
  end

  def cart_item_description(cart_item)
    beneficiary_info = cart_item.benefitable.present? ? "for #{cart_item.item_beneficiary_name}" : ""
    return "#{worldcon_public_name} #{cart_item.display_name} #{beneficiary_info}"
  end
end
