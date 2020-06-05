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

# A good way to test this out live is with the OAuth debugger:
# https://oauthdebugger.com/

# This is an attempt to make sure our library continues to meet expecations of the project
# We don't want to leak information outside of our app
RSpec.describe "SSO Integration Flows", type: :feature do
  let(:redirect_uri) { "https://oauthdebugger.com/debug" }

  let(:spoof_sso_url) do
    oauth_authorization_path(
      client_id: "non-existant-client-id", # non existant application
      nonce: "3rd-party-identifier-for-request",
      redirect_uri: "https://oauthdebugger.com/debug",
      scope: "read",
      response_type: "code",
      response_mode: "form_post",
    )
  end

  it "starts with no Doorkeeper::Applications" do
    expect(Doorkeeper::Application.count).to be 0
  end

  context "when visiting with no applications" do
    it "asks you to log in" do
      visit spoof_sso_url
      expect(page).to have_current_path(new_user_token_path)
      expect("Login Link").to be_in(page.body)
    end

    it "displays error when user has attending membership" do
      reservation = create(:reservation, :with_membership, :with_user)
      sign_in(reservation.user)
      visit spoof_sso_url
      expect(page).to have_content("Client authentication failed")
      expect(page).to have_content("unknown client")
    end
  end

  # You enable these integrations by using Doorkeeper::Application.create(
  #   name: "identity that makes sense to your con",
  #   redirect_uri: "https://something.you/expect_other_app_to_return_to",
  # )
  context "with integrations enabled" do
    let(:attending_user) { create(:user, :with_reservation) }
    let!(:sso) { create(:doorkeeper_application, redirect_uri: redirect_uri) }

    let(:sso_url) do
      oauth_authorization_path(
        client_id: sso.uid,
        redirect_uri: redirect_uri,
        scope: sso.scopes,
        response_mode: "form_post",
        response_type: "code",
        nonce: "nonce-metadata-42",
      )
    end

    it "starts with no Doorkeeper::Applications" do
      expect(Doorkeeper::Application.count).to be 1
    end

    it "will allow a signed in attending user to pass" do
      sign_in(attending_user)
      visit(sso_url)
      expect(page).to have_content("Authorize #{sso.name} to use your account?")

      # clicking authorize should take you out of the test
      # Cappybara raises an error due to the test harness, but we're ok with it
      # So long as our user is on the remote host
      expect { click_on("Authorize") }.to raise_error(ActionController::RoutingError)
      expect(page.current_url).to start_with(redirect_uri)
    end

    context "wouldn't let a user sign in when" do
      after do
        visit(sso_url)
        expect(page).to_not have_content("Authorize") # Doesn't have an Authorize button, or any metion of it
        expect(page).to_not have_content(sso.name)    # Doesn't mention the sign in service
      end

      it "is without memberships" do
        sign_in(create(:user))
      end

      it "has memberships, but none have attending rights" do
        reservation = create(:reservation, :with_user, membership: create(:membership, :pre_support))
        sign_in(reservation.user)
      end

      it "has attending membership, but it's not paid for" do
        reservation = create(:reservation, :with_user, :instalment, membership: create(:membership, :adult))
        sign_in(reservation.user)
      end
    end
  end
end
