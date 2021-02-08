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

module Acquirable
  # Acquirable is  a module that needs to be included in the model for
  # anything we want users to be able put in their shopping cart.
  #
  # Currently, it is included in Membership.
  #
  # Acquirable has a sibling module, Benefitable, that is included in the
  # model for ChicagoContact, DcContact, etc., so that those can become
  #  part of a CartItem instance alongside a Membership.

  extend ActiveSupport::Concern

  included do
    has_many :cart_items, :as => :aquirable
  end

  def acquirable_class
    self.acquirable_type
  end

end
