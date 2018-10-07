# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
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

# Test cards are here: https://stripe.com/docs/testing
class ChargesController < ApplicationController
  def index
  end

  def create
    service = ChargeCustomer.new(500, params[:stripeEmail], params[:stripeToken])
    @payment = service.call
    if !@payment
      flash[:error] = service.error_message
      redirect_to new_charge_path
    end
  end
end
