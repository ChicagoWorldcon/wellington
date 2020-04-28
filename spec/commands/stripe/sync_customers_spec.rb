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

require "rails_helper"

RSpec.describe Stripe::SyncCustomers do
  describe "#call" do
    subject(:call) { described_class.new.call }

    context "with customers in stripe, not in the members area" do
      let(:stripe_customer) { double(Stripe::Customer, email: "zibra@supervillain.net", id: "cus_5zZbB9321888c4") }

      before do
        expect(Stripe::Customer)
          .to receive_message_chain(:list, :auto_paging_each)
          .and_yield(stripe_customer)
      end

      it "creates new customers" do
        expect { call }.to change { User.count }.by(1)
        expect(User.last.email).to eq stripe_customer.email
        expect(User.last.stripe_customer_id).to eq stripe_customer.id
      end

      context "with mixed case email" do
        let(:stripe_customer) { double(Stripe::Customer, email: "Zibra@supervillain.net", id: "cus_556549321888c4") }

        it "still creates the customer, lower case email" do
          expect { call }.to change { User.count }.by(1)
          expect(User.last.email).to eq stripe_customer.email.downcase
        end
      end
    end

    context "with customers in both stripe and the members area" do
      let(:stripe_customer) { double(Stripe::Customer, email: "zibra@supervillain.net", id: "cus_5zZbB9321888c4") }
      let!(:user) { create(:user, :with_reservation, email: stripe_customer.email) }

      before do
        expect(Stripe::Customer)
          .to receive_message_chain(:list, :auto_paging_each)
          .and_yield(stripe_customer)
      end

      it "updates the user's stripe_customer_id" do
        expect { call }
          .to change { user.reload.stripe_customer_id }
          .from(nil).to(stripe_customer.id)
      end

      context "where the user already has a stripe id" do
        let(:a_while_back) { 1.week.ago }
        let!(:user) do
          create(:user, :with_reservation,
            stripe_customer_id: stripe_customer.id,
            email: stripe_customer.email,
            updated_at: a_while_back,
            created_at: a_while_back,
          )
        end

        it "doesn't change the user" do
          expect { call }.to_not change { user.updated_at }
        end
      end

      context "when the user's id is different in stripe" do
        let(:a_while_back) { 1.week.ago }
        let!(:user) do
          create(:user, :with_reservation,
            stripe_customer_id: "cus_sillyCustomerz",
            email: stripe_customer.email,
            updated_at: a_while_back,
            created_at: a_while_back,
          )
        end

        it "logs and doesn't change the user" do
          expect(Rails.logger).to receive(:warn).with(/preferring cus_sillyCustomerz/i)
          expect { call }.to_not change { user.updated_at }
        end
      end
    end
  end
end
