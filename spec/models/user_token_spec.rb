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
  context "with well formed format" do
    [
      "willy_wönka@chocolate_factory.nz",
      " outer@space.net",
      "outer@space.net ",
    ].each do |good_email|
      it "is valid with '#{good_email}'" do
        expect(UserToken.new(email: good_email)).to be_valid
      end
    end
  end

  context "for unhandled format" do
    [
      "",
      "embedded @space.net",
      "embedded@ space.net",
      "silly",
    ].each do |bad_email|
      it "is invalid with '#{bad_email}'" do
        expect(UserToken.new(email: bad_email)).to_not be_valid
      end
    end
  end
end
