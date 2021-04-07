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
  MEMBERSHIP = CartItem::MEMBERSHIP
  UNKNOWN = CartItem::UNKNOWN

  def initialize(full_params: f_params, bin_for_now: n_cart, item_kind: i_kind)
    @full_params = full_params
    @now_bin = bin_for_now
    @item_kind = item_kind
    @benefitable_required: benefitable_required?(item_kind)
  end

  def call
    binding.pry
    acquirable = resolve_acquirable
    return if acquirable.blank?

    binding.pry
    benefitable = resolve_benefitable
    return if (benefitable.blank? && @beneficiary_required)

    binding.pry
    benefitable.valid?  ?  benefitable.save : (export_validation_errors_to_flash(benefitable) and return)

    binding.pry
    create_cart_item(acquirable, benefitable)
  end

  private

  def benefitable_required?(item_kind)
    binding.pry
    case item_kind
    when MEMBERSHIP
      true
    else
      false
    end
  end

  def resolve_acquirable
    binding.pry
    case @item_kind
    when MEMBERSHIP
      extract_membership_info_from_params(@full_params)
    else
      UNKNOWN
    end
  end

  def resolve_benefitable(item_kind, full_params)
    binding.pry
    case item_kind
    when MEMBERSHIP
      generate_beneficiary_from_params(isolate_contact_params(full_params))
    else
      nil
    end
  end

  def extract_membership_info_from_params(f_params)
    binding.pry
    membership_offer = MembershipOffer.locate_active_offer_by_hashcode(f_params[:offer])
    export_membership_errors_to_flash if membership_offer.blank?
    membership_offer.membership
  end

  def isolate_contact_params(full_params)
    binding.pry
    full_params.require(theme_contact_param).permit(theme_contact_class.const_get("PERMITTED_PARAMS"))
  end

  def generate_beneficiary(contact_prms)
    binding.pry
    bf = theme_contact_class.new(contact_prms)
    return if bf.blank?

    binding.pry
    d_of_b = DateOfBirthParamsHelper.generate_dob_from_params(@full_params)
    bf.date_of_birth = d_of_b if (bf.present? && d_of_b.present?)

    binding.pry
    export_beneficiary_errors_to_flash(bf) if !bf.save
    return (bf.present? ? bf : nil)
  end

  def create_cart_item(acquirbl, benefitable: nil)
    binding.pry
    return if benefitable.blank? && @benefitable_required
    binding.pry
    cart_item_attributes = {
      :acquirable => acquirbl,
      :cart => @now_cart,
      :kind => @item_kind
    )
    binding.pry
    cart_item_attributes[:benefitable] = benefitable if benefitable.present?
    CartItem.create(cart_item_attributes)
  end

  def export_beneficiary_errors_to_flash(bf_iary)
    binding.pry
    flash[:error] = bf_iary.errors.full_messages.to_sentence(words_connector: ", and ").humanize.concat(".")
  end

  def export_membership_errors_to_flash
    binding.pry
    flash[:error] = t("errors.offer_unavailable", offer: @offer_params)
  end
end
