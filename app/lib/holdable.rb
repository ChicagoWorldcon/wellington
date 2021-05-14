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

module Holdable
  # Holdable is  a module that needs to be included in
  # the model for any kind of possessable digital object
  # that comes into being pursuant to the purchase of a
  # CartItem.
  #
  # At this time, the only Holdable is Reservation, but we
  # expect that others (such as Site Selection Tokens) are
  # likely to be added in the future.
  #
  # Holdable facilitates a polymorphic relationship within
  # CartItem.

  extend ActiveSupport::Concern

  included do
    has_one :cart_item, :as => :holdable
  end

  def holdable_class
    self.holdable_type
  end
end
