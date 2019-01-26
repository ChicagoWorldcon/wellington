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

RSpec.describe UpgradeMembership do
  subject(:command) { UpgradeMembership.new(purchase, to: upgrade_membership) }

  context "when upgrade is unavailable" do
    let(:membership) { create(:membership, :adult, :with_order_for_purchase) }
    let(:purchase) { membership.purchases.first }
    let(:upgrade_membership) { create(:membership, :young_adult) }

    it "returns false to indicate failure" do
      expect(subject.call).to be_falsey
    end

    it "incldues helpful error message" do
      expect { subject.call }
        .to change { subject.errors }
        .to include(/cannot upgrade to young adult/i)
    end

    it "doesn't change orders" do
      expect { subject.call }.to_not change { purchase.orders }
    end

    it "doesn't create new charges" do
      expect { subject.call }.to_not change { purchase.charges }
    end
  end
end
