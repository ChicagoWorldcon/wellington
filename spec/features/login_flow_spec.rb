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

RSpec.describe "Login Flow", type: :feature do
  include Warden::Test::Helpers
  after(:each) { Warden.test_reset! }

  let(:user) { create(:user) }
  let(:email_input) { "input[name=email]" }
  let(:submit_button) { "input[type=submit]" }

  context "when visiting new_user_token_path" do
    it "lets me sign in" do
      visit new_user_token_path
      expect(page).to have_css(email_input)
      expect(page).to have_css(submit_button)
    end

    it "redirects to root when signed in" do
      login_as(user)
      visit new_user_token_path
      expect(page).to have_current_path(root_path)
      expect(page).to_not have_css(email_input)
      expect(page).to_not have_css(submit_button)
    end
  end

  it "shows kansa user's 'expired' message" do
    visit "/login/willy_wonka@chocolate_factory.nz/DsfS3123"
    expect(page).to have_current_path(new_user_token_path)
    expect(page).to have_content(/expired/i)
  end
end
