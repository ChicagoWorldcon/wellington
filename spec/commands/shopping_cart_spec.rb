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

require "rails_helper"

RSpec.describe ShoppingCart do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  describe "#for" do
    subject(:command) { described_class.for(user) }
    let(:user) { create(:user) }

    it { is_expected.to be_kind_of(ShoppingCart) }

    it "updates User#stripe_customer_id if it's not set" do
      expect { command }.to change { user.stripe_customer_id }.from(nil)
    end

    it "doesn't change User#stripe_customer_id after it's set" do
      user.update!(stripe_customer_id: "existing id")
      expect { command }.to_not change { user.stripe_customer_id }.from("existing id")
    end
  end
end
