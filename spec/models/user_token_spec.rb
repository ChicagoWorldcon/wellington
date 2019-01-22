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

RSpec.describe UserToken do
  let(:good_email) { "willy_wönka@chocolate_factory.nz" }

  subject(:model) { UserToken.new(email: good_email) }
  it { is_expected.to be_valid }

  context "missing email" do
    subject(:model) { UserToken.new(email: "") }
    it { is_expected.to_not be_valid }
  end

  context "with bad email" do
    subject(:model) { UserToken.new(email: "not @good.net") }
    it { is_expected.to_not be_valid }
  end
end
