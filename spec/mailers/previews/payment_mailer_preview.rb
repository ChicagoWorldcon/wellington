# frozen_string_literal: true

# Copyright 2019 AJ Esler
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

class PaymentMailerPreview < ActionMailer::Preview
  include ThemeConcern

  StubReservation = Struct.new(:name, :number, :active_claim, :instalment?, :paid?, :membership) do
    def membership_number
      number
    end
  end
  StubClaim = Struct.new(:contact)
  StubUser = Struct.new(:email, :login_url)
  StubCharge = Struct.new(:id, :amount)

  def paid
    PaymentMailer.paid(
      user: Charge.for_item.last.user,
      charge: Charge.for_item.last
    )
  end

  def instalment
    PaymentMailer.instalment(
      user: Charge.for_item.last.user,
      charge: Charge.for_item.last,
      outstanding_amount: 42_00
    )
  end

  def waiting_for_cheque
    PaymentMailer.waiting_for_cheque(
      user: Charge.for_item.last.user,
      reservation: StubReservation.new("stub", 41, StubClaim.new(theme_contact_class.last)),
      outstanding_amount: 42_00
    )
  end
end
