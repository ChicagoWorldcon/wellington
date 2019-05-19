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

RSpec.describe MembershipsHeldSummary do
  let(:adult) { create(:membership, :adult) }
  let(:supporting) { create(:membership, :supporting) }
  let(:current_user) { create(:user) }
  subject(:query) { described_class.new(current_user) }

  describe "#to_s" do
    it "is empty with no memberships" do
      expect(query.to_s).to be_empty
    end

    it "is displays single membership without plural" do
      create(:purchase, user: current_user, membership: adult)
      expect(query.to_s).to eq "1 Adult Membership"
    end

    it "displays multiples of the same membership with plural" do
      create(:purchase, user: current_user, membership: adult)
      create(:purchase, user: current_user, membership: adult)
      expect(query.to_s).to eq "2 Adult Memberships"
    end

    it "displays mutliple membrership with plural" do
      create(:purchase, user: current_user, membership: adult)
      create(:purchase, user: current_user, membership: supporting)
      expect(query.to_s).to eq "1 Adult and 1 Supporting Memberships"
    end
  end
end
