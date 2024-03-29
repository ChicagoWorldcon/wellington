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

class CartServices::ResolveCartItem
  include ThemeConcern

  MEMBERSHIP = CartItem::MEMBERSHIP
  UNKNOWN = CartItem::UNKNOWN

  def initialize(full_params: f_params, bin_for_now: n_cart, item_kind: i_kind)
    @full_params = full_params
    @now_bin = bin_for_now
    @item_kind = item_kind
    @benefitable_required = benefitable_required?(item_kind)
    @error = ""
    @offer_param = full_params[:offer]
  end

  def call
    our_acquirable = resolve_acquirable
    return {cart_item: nil, error: @error} if our_acquirable.blank?

    our_benefitable = resolve_benefitable
    return {cart_item: nil, error: @error} if ((our_benefitable.blank? && @benefitable_required) || !our_benefitable.valid?)

    our_item = create_cart_item(our_acquirable, benefitable: our_benefitable)
    return {cart_item: our_item, error: @error}
  end

  private

  def benefitable_required?(item_kind)
    case item_kind
    when MEMBERSHIP
      true
    else
      false
    end
  end

  def resolve_acquirable
    case @item_kind
    when MEMBERSHIP
      extract_membership_info_from_params
    else
      nil
    end
  end

  def resolve_benefitable
    case @item_kind
    when MEMBERSHIP
      generate_beneficiary(isolate_contact_params)
    else
      nil
    end
  end

  def extract_membership_info_from_params
    membership_offer = MembershipOffer.locate_active_offer_by_hashcode(@offer_param)
    if (membership_offer.blank? || membership_offer.membership.blank?)
      format_membership_error(@offer_param) and return
    end
    membership_offer.membership
  end

  def isolate_contact_params
    @full_params.require(theme_contact_param).permit(theme_contact_class.const_get("PERMITTED_PARAMS"))
  end

  def generate_beneficiary(contact_params)
    bfry = theme_contact_class.new(contact_params)
    return if bfry.blank?

    d_of_b = DateOfBirthParamsHelper.generate_dob_from_params(@full_params)
    bfry.date_of_birth = d_of_b if (bfry.present? && d_of_b.present?)

    format_beneficiary_errors(bfry) if !bfry.save
    bfry.present? ? bfry : nil
  end

  def create_cart_item(acquirbl, benefitable: nil)
    if benefitable.blank? && @benefitable_required
      @error = "You must set a recipient for this item" and return
    end

    cart_item_attributes = {
      :acquirable => acquirbl,
      :cart => @now_bin,
      :kind => @item_kind
    }

    cart_item_attributes[:benefitable] = benefitable if benefitable.present?
    CartItem.create(cart_item_attributes)
  end

  def format_beneficiary_errors(bf_iary)
    @error = bf_iary.errors.full_messages.to_sentence(words_connector: ", and ").humanize.concat(".")
  end

  def format_membership_error(offer)
    @error =  "#{offer} is unavailable"
  end
end
