# frozen_string_literal: true

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

# ChargeDescription gives a description based on the state of the charge taking into account the time of the charge
# The goal is that you may build desciptions based on the history of charges against a reservation
# And to create a Charge#description with a hat tip to previous charge records
# And so that accountants get really nice text in reports

class CartContentsDescription
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  attr_reader :cart

  MYSQL_MAX_FIELD_LENGTH = 255
  MAX_CHARS_FOR_EMAIL_CART_DESCRIPTION = 10000
  MAX_CHARS_FOR_ONSCREEN_CART_DESCRIPTION = 10000

  def initialize(
    cart,
    with_prepended_con_name: false,
    with_repeating_con_name: false,
    with_layperson_uniq_id: false,
    for_email: false,
    for_screen: false,
    force_full_contact_name: false,
    base_per_item_estimate: 50,
    max_characters: nil
  )
    @cart = cart
    @with_prepended_con_name = with_prepended_con_name
    @with_repeating_con_name = with_repeating_con_name
    @for_email = for_email
    @for_screen = for_screen
    @force_full_contact_name = force_full_contact_name
    @cart_size = cart.cart_items.length
    @item_size_estimate = estimate_item_size(base_per_item_estimate)
    @max_chars = calc_max_characters(max_characters)
    @as_string = return_as_string?
    @shorten_beneficiary_name = self.truncate_beneficiary_name?
  end

  def describe_cart_contents
    cart_description_string_array = []
    cart_description_char_tally = 0

    cart.cart_items.each_with_index do |i, index|
      item_description_obj = describe_single_item_with_char_count(i, index)
      prospective_overall_length = item_description_obj[:character_count] + cart_description_char_tally

      finish_description_early = terminate_item_description_and_check_remaining_room(item_description_obj, index, prospective_overall_length)

      item_description_string = item_description_obj[:description_array].compact.join
      cart_description_string_array << item_description_string
      cart_description_char_tally += item_description_obj[:character_count]

      break if finish_description_early || cart_description_char_tally >= @max_chars
    end

    if @as_string
      return convert_description_array_to_string(cart_description_string_array)
    end

    cart_description_string_array
  end

  private

  def estimate_item_size(base_estimate)
    our_base = base_estimate
    our_base += 10 if @with_repeating_con_name
    our_base += 10 if @with_layperson_uniq_id
    our_base
  end

  def calc_max_characters(max_characters)
    #figure out max characters:
    # (If there is any ambiguity, defaults to the more restrictive mysql length)
    max_chars = max_characters
    max_chars ||= @for_screen ? MAX_CHARS_FOR_ONSCREEN_CART_DESCRIPTION : nil
    max_chars ||= @for_email ? MAX_CHARS_FOR_EMAIL_CART_DESCRIPTION : nil
    max_chars ||= ::ApplicationHelper::MYSQL_MAX_FIELD_LENGTH
  end

  def return_as_string?
    (@for_screen || @for_email) ? false : true
  end

  def truncate_beneficiary_name?
    # Figure out whether to use the shortened display name:
    return true if @force_full_contact_name
    @cart_size * @item_size_estimate >= @max_chars
  end

  def describe_single_item_with_char_count(item, index)
    our_description_object = {description_array: [], character_count: 0}

    if @with_repeating_con_name || (@with_prepended_con_name && index == 0)
      process_item_description_fragment("#{worldcon_public_name} ", our_description_object)
    end

    process_item_description_fragment("#{item.item_display_name} #{item.kind}", our_description_object)

    if @with_layperson_uniq_id
      process_item_description_fragment( " #{item.item_unique_id_for_laypeople}", our_description_object)
    end

    if item.benefitable.present?
      process_item_description_fragment(" for #{our_beneficiary_name(item)}", our_description_object)
    end

    our_description_object
  end

  def our_beneficiary_name(item)
    @shorten_beneficiary_name ? item.shortened_item_beneficiary_name : item.item_beneficiary_name
  end

  def process_item_description_fragment(fragment, description_object)
    description_object[:character_count] += fragment.length
    description_object[:description_array] << fragment
    description_object
  end

  def terminate_item_description_and_check_remaining_room(i_desc_obj, i_index, prospective_overall_char_count)
    conjunction_for_last_item = "and "
    finish_description_early = false
    space_remaining = @max_chars - prospective_overall_char_count
    steps_from_end = @cart_size - i_index - 1

    termination_string = ""

    if steps_from_end <= 0
      #Special behavior for last item:
      if space_remaining >= 4
        i_desc_obj[:description_array].unshift(conjunction_for_last_item)
        i_desc_obj[:character_count] += conjunction_for_last_item.length
      end
    elsif space_remaining < @item_size_estimate
      #Special behavior for when we're running out of space before the last item:
      termination_string = " and #{steps_from_end} other item(s)" if space_remaining >= 25
      finish_description_early = true
    else
      termination_string = ", "
    end

    process_item_description_fragment(termination_string, i_desc_obj)
    finish_description_early
  end

  def convert_description_array_to_string(desc_str_ary)
    desc_string = desc_str_ary.compact.join
    desc_string.lstrip!
    desc_string.rstrip!
    desc_string.delete_suffix!(",")

    if desc_string.length > @max_chars
       return desc_string[0, @max_chars]
    end

    desc_string
  end
end
