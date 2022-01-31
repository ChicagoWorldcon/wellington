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
  subject(:user) { create(:user, :with_reservation) }

  it { is_expected.to be_valid }

  it "shouldn't allow slashes in email addresses" do
    expect(build(:user, email: "harry/potter@hogwarts.net")).to_not be_valid
  end

  it "should canonicalize the provided email" do
    expect(build(:user, email: "Manual@Mail.com").email).to eq("manual@mail.com")
  end

  it "should retain the user provided email" do
    expect(build(:user, email: "Manual@Mail.com").user_provided_email).to eq("Manual@Mail.com")
  end

  # I felt the need to do this because factory code gets quite hairy, especially with factories calling factories from
  # the :with_reservation trait.
  describe "user factory links" do
    it "should be able to access reservation directly" do
      expect(user.reservations).to include user.claims.active.first.reservation
    end

    it "should have a charge equal to the price of the membership" do
      expect(user.charges.first.amount).to eq user.reservations.first.membership.price
    end
  end

  context "duplicate email addresses" do
    let(:double_up_email) { "pants-optional@perfect-underwear.co.uk" }
    let(:first_user) { create(:user, email: double_up_email) }
    let(:second_user) { build(:user, email: double_up_email) }

    it "doens't let the second user sign up" do
      expect(first_user).to be_valid
      expect(second_user).to_not be_valid
      expect(second_user.errors[:email]).to include(/taken/i)
    end
  end
end
