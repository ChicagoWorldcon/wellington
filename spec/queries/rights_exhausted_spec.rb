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

RSpec.describe RightsExhausted do
  subject(:query) { described_class.new(reservation) }

  let(:reservation) { create(:reservation, :with_user) }

  describe "#call" do
    subject(:call) { query.call }

    it "is empty initially" do
      expect(call).to be_empty
    end

    it "flags nominations when they're used" do
      create(:nomination, reservation: reservation)
      expect(call).to include(/nomination/i)
    end

    it "flags hugo packet when downloaded" do
      reservation.user.update!(hugo_download_counter: 1)
      expect(call).to include(/hugo packet/i)
    end
  end
end
