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

class PriceAndNameMemoValidator < ActiveModel::Validator
  def validate(record)
    return if record.acquirable.blank?
    if record.acquirable.name != record.item_name_memo
      record.errors.add(:item_name_memo, :item_identity_divergence, message: "This #{record.kind} has changed materially since you added it to your cart, and has now expired.")
    end

    if record.acquirable.price_cents != record.item_price_memo
      record.errors.add(:item_price_memo, :item_price_divergence, message: "This #{record.kind} has changed its price since you added it to your cart, and has now expired.")
    end
  end
end
