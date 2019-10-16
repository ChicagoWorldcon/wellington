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

class NominationsController < ApplicationController
  before_action :lookup_reservation!
  before_action :lookup_category, only: :create

  def index
    builder = MemberNominationsByCategory.new(reservation: @reservation).from_reservation
    @nominations_by_category = builder.nominations_by_category
    @privacy_warning = current_user.reservations.count > 1
  end

  def create
    builder = MemberNominationsByCategory.new(reservation: @reservation).from_reservation
    @nominations_by_category = builder.nominations_by_category
    render "nominations/index"
  end

  private

  def lookup_category
    @category = Category.find(params[:category_id])
  end
end
