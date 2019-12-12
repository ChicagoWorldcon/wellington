# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2019 Steven C Hartley
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

RSpec.describe UserTokensController, type: :controller do
  let(:user) { create(:user) }
  let(:jwt_secret) { "unguessable jwt secret" }

  before do
    @real_jwt_secret = ENV["JWT_SECRET"]
    ENV["JWT_SECRET"] = jwt_secret
  end

  after do
    ENV["JWT_SECRET"] = @real_jwt_secret
  end

  describe "#create" do
    it "sets error when email is invalid" do
      post :create, params: { email: "please like and subscribe" }
      expect(flash[:error]).to be_present
      expect(flash[:notice]).to_not be_present
    end
  end

  # Note, this is also has a feature spec in spec/features/login_flow_spec.rb
  describe "#show" do
    let(:user) { create(:user) }
    let(:user_token) { "asdf" }
    let(:good_email) { "willy_wönka@chocolate_factory.nz" }
    let(:valid_login_path) { "/reservations/new" }
    let(:valid_login_path_token) { JWT.encode({exp: (Time.now + 10.minutes).to_i, email: good_email, path: "/reservations/new", }, ENV["JWT_SECRET"], "HS256") }
    let(:invalid_login_path_token) { JWT.encode({exp: (Time.now + 10.minutes).to_i, email: good_email, path: "/notarealpath", }, ENV["JWT_SECRET"], "HS256") }

    context "when secret is not set" do
      let(:jwt_secret) { nil }

      it "doesn't login" do
        get :show, params: { id: user_token }
        expect(response).to have_http_status(302)
      end

      it "sets flash error" do
        get :show, params: { id: user_token }
        expect(flash[:error]).to match(/secret/i)
      end
    end

    context "when login path is valid" do
      it "redirects to login path" do
        get :show, params: { id: valid_login_path_token}
        expect(response).to redirect_to(valid_login_path)
      end
    end

    context "when login path is invalid" do
      it "redirects to root_path" do
        get :show, params: { id: invalid_login_path_token}
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "#logout" do
    it "signs the current user out" do
      sign_in(user)
      expect { get :logout }.to change { controller.current_user }.to(nil)
    end
  end
end
