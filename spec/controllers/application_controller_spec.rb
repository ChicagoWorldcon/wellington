# frozen_string_literal: true
#
# Copyright 2021 Victoria Garcia
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

RSpec.describe ApplicationController, type: :controller do
  render_views
  let(:naive_user) { create(:user) }
  let(:locked_user) { create(:user, :with_offer_lock_date) }
  let(:support_user) {create(:support) }

  describe "public instance methods" do
    describe "#lookup_effective_offer_date!" do

      before do
        sign_out(controller.current_user) if controller.current_user.present?
      end

      context "when a user without a lock date is signed in" do
        before do
          sign_in(naive_user)
        end

        after do
          sign_out(naive_user)
        end
        it "has a test that is set up as expected" do
          expect(controller.current_user).to be
          expect(controller.current_user).to eq(naive_user)
          expect(controller.current_user.offer_lock_date).to be_nil
        end

        it "reports today as the effecive offer lock date" do
          controller.lookup_effective_offer_date!
          expect(assigns(:effective_offer_date)).to_not be nil
          expect(assigns(:effective_offer_date)).to be_within(1.day).of(Time.now)
        end
      end

      context "when a user with a lock date is signed in" do
        before do
          sign_in(locked_user)
        end

        after do
          sign_out(locked_user)
        end

        it "has a test that is set up as expected" do
          expect(controller.current_user).to be
          expect(controller.current_user).to eq(locked_user)
          expect(controller.current_user.offer_lock_date).to be
        end

        it "reports nine months ago as the effecive offer lock date" do
          controller.lookup_effective_offer_date!
          expect(assigns(:effective_offer_date)).to_not be nil
          expect(assigns(:effective_offer_date)).to be_within(1.day).of(Time.now - 9.months)
        end
      end

      context "when a support user is signed in" do
        before do
          sign_in(support_user)
        end

        after do
          sign_out(support_user)
        end

        it "has a test that is set up as expected" do
          expect(controller.current_user).to be nil
          expect(controller.support_signed_in?).to eql(true)
        end

        it "reports today as the effecive offer lock date" do
          controller.lookup_effective_offer_date!
          expect(assigns(:effective_offer_date)).to_not be nil
          expect(assigns(:effective_offer_date)).to be_within(1.day).of (Time.now)
        end
      end

      context "when no user is signed in" do
        before do
          sign_out(controller.current_user) if controller.current_user.present?
        end

        it "has a test that is set up as expected" do
          expect(controller.current_user).to_not be
        end

        it "reports today as the effecive offer lock date" do
          controller.lookup_effective_offer_date!
          expect(assigns(:effective_offer_date)).to_not be nil
          expect(assigns(:effective_offer_date)).to be_within(1.day).of(Time.now)
        end
      end
    end
  end
end
