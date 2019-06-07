# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
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

class Membership < ApplicationRecord
  include ActiveScopes

  validates :active_from, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :name, presence: true

  has_many :orders
  has_many :active_orders, -> { active }, class_name: "Order"
  has_many :reservations, through: :active_orders

  scope :order_by_price, -> { order(price: :desc) }

  def to_s
    name.humanize
  end

  def membership_rights
    [].tap do |rights|
      rights << I18n.t("rights.attend") if can_attend?
      rights << I18n.t("rights.vote_hugo") if can_vote?
      rights << I18n.t("rights.nominate_hugo") if can_vote?
      rights << I18n.t("rights.nominate_site_selection") if can_vote?
    end
  end
end
