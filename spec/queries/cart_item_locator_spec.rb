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

require "rails_helper"

RSpec.describe CartItemLocator do

  subject(:query) { described_class.new(our_user: user, our_item_id: item_id) }

  xdescribe "#locate_current_cart_item_for_user" do
    subject(:ct_item_for_user) { query.locate_current_cart_item_for_user }
    pending
  end

  xdescribe "#cart_items_for_now" do
    subject(:ct_items_for_now) { query.cart_items_for_now}
    pending
  end

  xdescribe "#cart_items_for_later" do
    subject(:ct_items_for_later) { query.cart_items_for_later}
    pending
  end

  xdescribe "#all_current_cart_items" do
    subject(:all_curr_ct_items) { query.all_current_cart_items}
    pending
  end

  xdescribe "#all_membership_items_for_now" do
    subject(:all_memb_items_for_n) { query.all_membership_items_for_now}
    pending
  end

  xdescribe "#all_reservations_from_cart_items_for_now" do
    subject(:all_res_for_n) { query.all_reservations_from_cart_items_for_now}
    pending
  end

  xdescribe "#all_reservations_from_cart_items_for_later" do
    subject(:all_res_for_l) { query.all_reservations_from_cart_items_for_later}
    pending
  end

  xdescribe "#all_reservations_from_cart_items_for_later" do
    subject(:all_current_res) { query.all_reservations_from_cart_items_for_later}
    pending
  end
end
