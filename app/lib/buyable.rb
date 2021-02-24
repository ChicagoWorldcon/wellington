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

module Buyable
  # Buyable is  a module that needs to be included in
  # the model for anything that is going to be the basis of
  # a Stripe charge.  (As of this writing, that's Reservation and Cart.
  #
  # It facilitates a polymorphic association within Charge.

  extend ActiveSupport::Concern

  included do
    has_many :charges, :as => :buyable
  end

  def buyable_class
    self.buyable_type
  end
end
