# frozen_string_literal: true
#
# Copyright 2021 Victoria Garcia
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

module CartItemsHelper

  # TODO: Figure out a better way to do this. This
  # is unweildy and I'm pretty sure we can do this more directly.
  def self.locate_offer(offer_params)
    binding.pry
    target_offer = MembershipOffer.options.find do |offer|
      offer.hash == offer_params
    end
    if !target_offer.present?
      flash[:error] = t("errors.offer_unavailable", offer: offerParams)
    end
    target_offer
  end

  def locate_offer(offer_params)
    CartItemsHelper.locate_offer(offer_params)
  end

  def self.cart_items_for_now(cart)
    now_items = []
    cart.cart_items.each {|item|
      if item.later == false
        now_items << item
      end
    }
    now_items
  end

  def cart_items_for_now(cart)
    CartItemsHelper.cart_items_for_now(cart)
  end

  def self.cart_items_for_later(cart)
    later_items = []
    cart.cart_items.each {|item|
      if item.later == true
        later_items << item
      end
    }
    later_items
  end

  def cart_items_for_later(cart)
    CartItemsHelper.cart_items_for_later(cart)
  end

  def self.verify_availability_of_cart_contents(cart)
    binding.pry
    all_contents_available = true;
    cart.cart_items.each {|item|
      all_contents_available = all_contents_available && item.item_still_available?
    }
    return all_contents_available
  end

  def verify_availability_of_cart_contents(cart)
    CartItemsHelper.verify_availability_of_cart_contents(cart)
  end
end
