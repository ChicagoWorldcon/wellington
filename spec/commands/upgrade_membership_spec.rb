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
  subject(:command) { UpgradeMembership.new(purchase, level) }

  context "when upgrade unavailable" do
    let(:level) { "young_adult" }
    let(:purchase) { create(:purchase, level: :adult) }

    it "returns false to indicate failure" do
      expect(subject.call).to be_falsey
      expect(subject.errors).to include(/cannot upgrade to young_adult/i)
    end

    it "doesn't change purchase level" do
      expect { subject.call }.to_not change { purchase.level }
    end

    it "doesn't create new charges" do
      expect { subject.call }.to_not change { purchase.charges.count }
    end
  end

  context "when upgrade is available" do
    let(:level) { "adult" }
    let(:purchase) { create(:purchase, level: :young_adult) }

    it "returns true to indicate success" do
      expect(subject.call).to be_truthy
      expect(subject.errors).to be_empty
    end

    it "doens't change the number of memberships" do
      purchase
      expect { subject.call }.to_not change { Purchase.count }
    end

    it "changes purchase level" do
      expect { subject.call }
        .to change { purchase.level }
        .from("young_adult").to("adult")
    end
  end
end
