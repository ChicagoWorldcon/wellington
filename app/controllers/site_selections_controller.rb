# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
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

# Site selection controller allows a user to purchase a site selection token
# This is separate from charges controller because we need a differnet bucket for money
# taken in from site selection tokens
class SiteSelectionsController < ApplicationController
  before_action :lookup_reservation!
  before_action :assert_token_unpurchased!

  # Note, @reservation is based on id in the url
  def show
  end

  def create
    site_seleciton = SiteSelection.create!(reservation: @reservation)
    flash[:notice] = "Congratulations! Your site selection token is #{site_seleciton.token}"
    redirect_to reservations_path
  end

  private

  def assert_token_unpurchased!
    if @reservation.site_selection.present?
      flash[:notice] = "Already purchased site selection token. Your number is #{@reservation.site_selection.token}"
      redirect_to reservations_path
    end
  end
end
