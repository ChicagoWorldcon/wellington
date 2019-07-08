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

# CreditsController allows us to list and grant account credit to a user
class CreditsController < ApplicationController
  before_action :assert_support!
  before_action :lookup_reservation!

  def new
    @amount_owed = AmountOwedForReservation.new(@reservation).amount_owed
    @credit = PlanCredit.new
  end

  def create
    credit_params = params.require(:plan_credit).permit(:amount)
    plan = PlanCredit.new(credit_params)
    if !plan.valid?
      flash[:error] = plan.errors.full_messages.to_sentence
      redirect_to @reservation
      return
    end

    ApplyCredit.new(@reservation, plan.money, audit_by: current_support.email).call
    flash[:notice] = "Credited ##{@reservation.membership_number} with #{plan.money.format}"
    redirect_to @reservation
  end
end
