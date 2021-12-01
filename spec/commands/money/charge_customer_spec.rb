# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2019 AJ Esler
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

RSpec.describe Money::ChargeCustomer do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  let(:membership) { reservation.membership }
  let(:user) { create(:user) }
  let(:amount_owed) { membership.price }
  let(:token) { stripe_helper.generate_card_token }

  let(:reservation) do
    create(:reservation,
      :with_order_against_membership,
      :instalment,
      instalment_paid: 0,
      user: user
    )
  end

  let(:unpaid_res_cart) { create(:cart, :with_unpaid_reservation_items)}
  let(:unpaid_r_c_user) { unpaid_res_cart.user }
  let(:owed_for_unpd_cart ) { Money.new(CentsOwedForCartContents.new(unpaid_res_cart).owed_cents) }

  describe "#comment" do
    let(:amount_1) { Money.new(1_00) }
    let(:amount_2) { membership.price - amount_1 }

    it "displays purchase state as we go" do
      described_class.new(reservation, user, token, amount_1).call
      expect(Charge.last.comment).to match(/instalment/i)
      described_class.new(reservation, user, token, amount_2).call
      expect(Charge.last.comment).to match(/fully paid/i)
    end
  end

  describe "mocking reservation charge description" do
    let(:comment_for_users) { "Fab Zibra is yours" }
    let(:comment_for_accounts) { "Stripey Zibra Paid" }

    before do
      expect(ChargeDescription)
        .to receive(:new).at_least(:once)
        .and_return(
          instance_double(ChargeDescription,
            for_accounts: comment_for_accounts,
            for_users: comment_for_users
          )
        )
      end


    context "when stripe customer id is already set" do
      subject(:command) { described_class.new(reservation, user, token, amount_owed) }
      let(:initial_stripe_id) { "super vip customer" }

      let(:user) { create(:user, stripe_id: initial_stripe_id) }
      it "doesn't set stripe ID again" do
        expect(Stripe::Customer).to_not receive(:create)
        expect { command.call }
          .to_not change { user.reload.stripe_id }
          .from(initial_stripe_id)
      end
    end

    context "when paying for a reservation" do
      subject(:command) { described_class.new(reservation, user, token, amount_owed) }

      it "updates user's stripe id" do
        expect { command.call }.to change { user.reload.stripe_id }.from(nil)
      end

      context "when payment fails" do
        before do
          StripeMock.prepare_card_error(:card_declined)
          expect(command.call).to be_falsey
        end

        it "does not change the amount paid" do
          expect { command.call }.not_to change { reservation.reload.charges.successful.sum(&:amount) }
        end

        it "creates a failed payment on card decline" do
          expect(Charge.failed.count).to eq 1
          expect(Charge.last.stripe_id).to be_present
          expect(reservation).to be_instalment
        end

        it "delegates the description to our charge description service" do
          expect(Charge.last.comment).to eq comment_for_users
        end
      end

      context "when payment succeeds" do
        before do
          expect(command.call).to be_truthy
        end

        it "creates a new successful charge" do
          expect(Charge.successful.count).to eq(1)
          expect(Charge.last.stripe_id).to be_present
        end

        it "is linked to our user" do
          expect(Charge.last.user).to eq user
        end
      end
    end

    context "when paying only part of a reservation" do
      let(:amount_paid) { membership.price / 4 }
      let(:amount_left) { membership.price - amount_paid }
      subject(:command) { described_class.new(reservation, user, token, amount_left, charge_amount: amount_paid) }

      it "creates a failed payment on card decline" do
        StripeMock.prepare_card_error(:card_declined)
        expect(command.call).to be_falsey
        expect(Charge.failed.count).to eq 1
        expect(Charge.last.stripe_id).to be_present
        expect(Charge.last.amount).to eq amount_paid
      end

      context "when payment succeeds" do
        before do
          expect(command.call).to be_truthy
        end

        it "creates a new successful charge" do
          expect(Charge.successful.count).to eq(1)
          expect(Charge.last.stripe_id).to be_present
        end

        it "is of the value passsed in" do
          expect(Charge.last.amount).to eq amount_paid
        end

        it "marks reservation state as instalment" do
          expect(reservation).to be_instalment
        end

        it "does not log the current membership as the last fully paid" do
          expect { command.call }
          .to_not change { reservation.reload.last_fully_paid_membership }
          .from(nil)
        end

        context "then membership pricing changes" do
          let(:price_increase) { Money.new(1_00) }
          before do
            price_changed_at = 30.minutes.ago
            membership.update!(active_to: price_changed_at)
            expect(membership).to_not be_active_at(price_changed_at)

            new_membership = membership.dup                          # based on attrs from existing membership
            new_membership.active_from = price_changed_at            # starts from price change
            new_membership.active_to = nil                           # open ended
            new_membership.price = membership.price + price_increase # price goes up
            new_membership.save!

            expect(new_membership).to be_active_at(price_changed_at)
            expect(membership.price).to be < new_membership.price
          end

          it "pays off the membership at the original price" do
            success = described_class.new(reservation, user, token, amount_left, charge_amount: amount_left).call
            expect(success).to be_truthy
            expect(reservation.state).to eq(Reservation::PAID)
          end
        end
      end
    end

    context "when overpaying" do
      let(:amount_paid) { membership.price + Money.new(1) }
      let(:amount_owed) { membership.price }
      subject(:command) { described_class.new(reservation, user, token, amount_owed, charge_amount: amount_paid) }

      it "refuses to reservation the reservation" do
        expect(command.call).to be_falsey
        expect(command.errors).to include(/Overpay/i)
      end
    end

    context "when paying off a reservation" do
      let(:partial_pay) { membership.price / 4 }
      let(:remainder) { membership.price - partial_pay }
      let(:overpay) { remainder + Money.new(1) } # just a cent over
      let(:amount_owed) { remainder }

      before do
        described_class.new(reservation, user, token, membership.price, charge_amount: partial_pay).call
      end

      subject(:command) { described_class.new(reservation, user, token, amount_owed, charge_amount: remainder) }

      it { is_expected.to be_truthy }

      it "transitions from instalment" do
        expect { command.call }
          .to change { reservation.state }
          .from(Reservation::INSTALMENT).to(Reservation::PAID)
      end

      it "logs the current membership as last fully paid" do
        expect { command.call }
          .to change { reservation.last_fully_paid_membership }
          .from(nil)
          .to(reservation.membership)
      end

      it "creates a charge" do
        expect { command.call }
          .to change { Charge.count }
          .by(1)
      end

      context "when choosing to overpay" do
        subject(:command) { described_class.new(reservation, user, token, amount_owed, charge_amount: overpay) }

        it "gives a polite error" do
          expect(command.call).to be_falsey
          expect(command.errors).to include(/Overpay/i)
        end
      end

      context "with default behaviour" do
        subject(:command) { described_class.new(reservation, user, token, amount_owed) }

        it { is_expected.to be_truthy }

        it "transitions from instalment" do
          expect { command.call }
            .to change { reservation.state }
            .from(Reservation::INSTALMENT).to(Reservation::PAID)
        end

        it "only pays the price of the membership" do
          command.call
          expect(user.charges.successful.sum(&:amount)).to eq membership.price
        end
      end
    end
  end

  context "when paying for a cart" do

    subject(:our_helper) { described_class.new(unpaid_res_cart, unpaid_r_c_user, token, owed_for_unpd_cart)}

    it "updates the user's stripe id" do
        expect { our_helper.call }.to change { unpaid_r_c_user.reload.stripe_id }.from(nil)
    end

    context "when payment in full is attempted" do
      context "when payment succeeds" do
        before do
          expect(our_helper.call).to be_truthy
        end

        it "creates a new successful charge" do
          expect(Charge.successful.count).to eq 1
          expect(Charge.last.stripe_id).to be_present
        end

        it "updates the payment status of all the reservations in the cart to 'paid'" do
          paids_seen = unpaid_res_cart.cart_items.inject(0) {|a, i| a += 1 if (i.holdable.state == Reservation::PAID) }
          expect(paids_seen).to eql(unpaid_res_cart.cart_items.count)
        end

        it "is linked to our user" do
          expect(Charge.last.user).to eq unpaid_r_c_user
        end

        it "delegates the description to our charge description service" do
          expect(Charge.last.comment).to eq(ChargeDescription.new(Charge.last).for_cart_transactions)
        end
      end

      context "when payment fails" do
        before do
          StripeMock.prepare_card_error(:card_declined)
          expect(our_helper.call).to be_falsey
        end

        it "does not change the amount paid" do
          expect { our_helper.call }.not_to change { unpaid_res_cart.reload.charges.successful.sum(&:amount) }
        end

        it "creates a failed payment on card decline" do
          expect(Charge.failed.count).to eq 1
          expect(Charge.last.stripe_id).to be_present
        end

        it "assigns a message about the card being declined to the charge's comment field" do
          expect(Charge.last.comment).to match(/declined/i)
        end
      end
    end

    context "when attempting to underpay for a cart" do
      subject(:our_underpayment_helper) { described_class.new(unpaid_res_cart, unpaid_r_c_user, token, owed_for_unpd_cart, charge_amount: Money.new(200))}

      before do
        our_underpayment_helper.call
      end

      it "does not change the amount paid" do
        expect { our_underpayment_helper.call }.not_to change { unpaid_res_cart.reload.charges.successful.sum(&:amount) }
      end

      it "creates a failed payment" do
        expect(Charge.failed.count).to eq 1
        expect(Charge.last.stripe_id).to be_present
      end

      it "assingns the error message to the charge's comment field" do
        expect(Charge.last.comment).to match(/paid for in full or not at all/i)
      end
    end
  end
end
