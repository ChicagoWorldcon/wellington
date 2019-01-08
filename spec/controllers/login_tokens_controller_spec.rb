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

RSpec.describe LoginTokensController, type: :feature do
  let(:email_input) { "input[name=email]" }
  let(:submit_button) { "input[type=submit]" }

  describe "#new" do
    it "lets me sign in" do
      visit "/login_tokens/new"
      expect(page).to have_css(email_input)
      expect(page).to have_css(submit_button)
    end
  end
end
