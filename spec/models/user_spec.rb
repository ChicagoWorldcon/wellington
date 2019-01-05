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

RSpec.describe User, type: :model do
  subject(:user) { create(:user, :with_purchase) }

  it { is_expected.to be_valid }

  # I felt the need to do this because factory code gets quite hairy, especially with factories calling factories from
  # the :with_purchase trait.
  describe "user factory links" do
    it "should be able to access purchase directly" do
      expect(user.purchases).to include user.claims.active.first.purchase
    end

    it "should have a charge equal to the price of the membership" do
      expect(user.charges.first.amount).to eq user.purchases.first.membership.price
    end
  end

  describe "#login_token" do
    let(:secret) { "flubber" }
    subject(:jwt_token) { user.login_token(secret) }
    it { is_expected.to_not be_nil }

    context "when used with User#lookup_token!" do
      it "finds the original user" do
        expect(User.lookup_token!(secret, jwt_token: jwt_token)).to eq(user)
      end
    end
  end

  describe "User#lookup_token!" do
    let(:secret) { "flubber" }
    let(:token) { JWT.encode(login_info, secret, "HS256") }

    context "with expired token" do
      let(:login_info) do
        {
          exp: 1.second.ago.to_i,
          email: user.email,
        }
      end

      it "raises exception" do
        expect { User.lookup_token!(secret, jwt_token: token) }.to raise_error(JWT::ExpiredSignature)
      end
    end

    context "with unfound user" do
      let(:login_info) do
        {
          exp: 10.seconds.from_now.to_i,
          email: "never gonna give you up",
        }
      end

      it "returns nil" do
        expect(User.lookup_token!(secret, jwt_token: token)).to be_nil
      end
    end

    context "with credentials of legit user" do
      let(:login_info) do
        {
          exp: 10.seconds.from_now.to_i,
          email: user.email,
        }
      end

      it "returns nil" do
        expect(User.lookup_token!(secret, jwt_token: token)).to eq(user)
      end
    end
  end
end
