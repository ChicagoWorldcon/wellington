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

RSpec.describe ApplicationHelper, type: :helper do
  describe "#membership_right_description" do
    subject(:membership_right_description) { helper.membership_right_description(membership_right, reservation) }
    let(:election) { create(:election) }
    let(:election_name) { election.name.downcase }
    let(:reservation) { create(:reservation, :with_order_against_membership) }

    context "before nominations open" do
      let(:membership_right) { "rights.#{election_name}.nominate_soon" }

      it "doesn't link to hugo" do
        expect(membership_right_description).to_not include("<a href=")
      end
    end

    context "after nominations open" do
      let(:membership_right) { "rights.#{election_name}.nominate" }

      it "links to hugo" do
        expect(membership_right_description).to include("<a href=")
      end
    end
  end
end
