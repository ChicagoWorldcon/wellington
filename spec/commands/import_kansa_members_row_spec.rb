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

require "rails_helper"

RSpec.describe ImportKansaMembersRow do
  let!(:adult)       { create(:membership, :adult) }
  let!(:silver_fern) { create(:membership, :silver_fern) }
  let!(:kiwi)        { create(:membership, :kiwi) }

  let(:email_address) { Faker::Internet.email }
  let(:my_comment) { "suite comment" }
  let(:stripe_payment_id) { "ch_1D0MiPEaQ9ZgIF2tWbUtFOnz" }
  let(:charge_amount) { 37000 }
  let(:payment_comment) { "Imported payment of #{charge_amount} paid by charge #{stripe_payment_id}" }
  let(:note) { "Enjoys long walks on the beach" }
  let(:member_number) { 7474 }

  subject(:command) { ImportKansaMembersRow.new(row_values, my_comment) }

  let(:row_values) do
    [
      Faker::FunnyName.three_word_name, # Full name
      Faker::Name.first_name,           # PreferredFirstname
      Faker::Name.last_name,            # PreferedLastname
      Faker::Superhero.name,            # BadgeTitle
      Faker::Superhero.descriptor,      # BadgeSubtitle
      Faker::Address.street_address,    # Address Line1
      Faker::Address.secondary_address, # Address Line2
      Faker::Address.country,           # Country
      email_address,                    # Email Address
      note,                             # Notes
      "Silver Fern Pre-Support",        # Membership Status
      stripe_payment_id,                # Stripe Payment ID
      charge_amount,                    # Charge Amount
      payment_comment,                  # Payment Comment
      member_number,                    # Member Number
    ]
  end

  context "with one member" do
    it "executes successfully" do
      expect(command.call).to be_truthy
      expect(command.errors).to be_empty
    end

    it "imports a member" do
      expect { command.call }.to change { User.count }.by(1)
      expect(User.last.email).to eq email_address
    end

    it "puts a new active order against that membership" do
      expect { command.call }.to change { silver_fern.reload.active_orders.count }.by(1)
      expect(User.last.purchases).to eq(silver_fern.purchases)
    end

    context "after run" do
      before do
        command.call
      end

      it "creates a stripe charge" do
        expect(User.last.charges.successful.stripe.count).to be(1)
      end

      it "sets the charge comment" do
        expect(Charge.last.comment).to match(payment_comment)
      end

      it "sets the charge amount" do
        expect(Charge.last.amount).to match(charge_amount)
      end

      it "sets the stripe payment id" do
        expect(Charge.last.stripe_id).to match(stripe_payment_id)
      end

      it "sets membership to paid" do
        expect(Purchase.last.state).to eq Purchase::PAID
      end

      it "sets the membership number" do
        expect(Purchase.last.membership_number).to eq member_number
      end

      it "set the user note" do
        expect(User.last.notes.first.content).to eq note
      end
    end
  end
end
