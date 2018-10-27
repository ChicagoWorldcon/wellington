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

RSpec.describe Purchase, type: :model do
  context "when adult" do
    subject(:model) { create(:purchase, level: :adult) }
    it { is_expected.to be_valid }
    it { is_expected.to be_transferable }
  end

  context "when not active as an adult" do
    [Purchase::INSTALLMENT, Purchase::DISABLED].each do |inactive_state|
      subject(:model) { create(:purchase, level: :adult, state: inactive_state) }
      it { is_expected.to be_valid }
      it { is_expected.to_not be_transferable }
    end
  end

  context "for presupport purchases" do
    %i(silver_fern kiwi tuatara).each do |presupport_level|
      subject(:model) { create(:purchase, level: presupport_level) }
      it { is_expected.to be_valid }
      it { is_expected.to_not be_transferable }
    end
  end
end
