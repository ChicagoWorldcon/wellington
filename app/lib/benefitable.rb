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

module Benefitable
  # Benefitable is a sibling module to Acquirable.  It needs to be included # in the model for things like ChicagoContact, DcContact, etc, that
  # represent a person whose information forms a key part of an item
  # being purchased via the shopping cart. In the case of memberships, it
  # represents the identity of the prospective membership holder.  (As
  # distinct from the User, who is the owner of the shopping cart, and who # will be the one making the purchase.)

  extend ActiveSupport::Concern

  included do
    has_many :cart_items, :as => :benefitable
  end

  def benefitable_class
    self.benefitable_type
  end
end
