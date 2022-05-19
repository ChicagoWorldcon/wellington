# frozen_string_literal: true

# Copyright 2020 Steven Ensslen
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

RSpec.describe HugoPacketController, type: :controller do
  render_views

  let(:adult) { create(:membership, :adult) }
  let(:dublin) { create(:membership, :dublin_2019) }
  let(:voting_open) { true }

  before do
    ENV["AWS_ACCESS_KEY_ID"] = "much-id"
    ENV["AWS_REGION"] = "ap-southeast-2"
    ENV["AWS_SECRET_ACCESS_KEY"] = "so-secret"
  end

  before(:each) do
    expect(HugoState)
      .to receive_message_chain(:new, :has_voting_opened?)
      .and_return(voting_open)
  end

  describe "#index" do
    context "when voting isn't open and logged in" do
      let(:reservation) { create(:reservation, :with_claim_from_user, membership: dublin) }
      let(:voting_open) { false }
      before { sign_in(reservation.user) }

      it "flashes that voting isn't open" do
        get(:index)
        expect(flash[:notice]).to match(/voting is not open/i)
      end
      it "redirects to the root" do
        expect(get(:index)).to redirect_to(root_path)
      end
    end

    context "when voting isn't open and logged out" do
      let(:voting_open) { false }
      it "redirects to the root" do
        expect(get(:index)).to redirect_to(root_path)
      end
      it "flashes a login notice" do
        get(:index)
        expect(flash[:notice]).to match(/voting is not open/i)
      end
    end

    context "when voting is open and logged out" do
      it "redirects to the root" do
        expect(get(:index)).to redirect_to(root_path)
      end
      it "flashes a login notice" do
        get(:index)
        expect(flash[:notice]).to match(/please log in/i)
      end
    end

    context "when logged in without voting rights" do
      let(:reservation) { create(:reservation, :with_claim_from_user, membership: dublin) }
      before { sign_in(reservation.user) }

      it "redirects with error" do
        expect(get(:index)).to redirect_to(reservations_path)
        expect(flash[:notice]).to match(/voting rights/i)
      end
    end

    context "when logged with voting rights but not paid" do
      let(:reservation) do
        create(:reservation, :with_claim_from_user, :instalment, instalment_paid: 0, membership: adult)
      end
      before { sign_in(reservation.user) }

      it "redirects with error" do
        expect(get(:index)).to redirect_to(reservations_path)
        expect(flash[:notice]).to match(/voting rights/i)
      end
    end

    context "when logged with voting rights" do
      let(:reservation) { create(:reservation, :with_claim_from_user, membership: adult) }
      before { sign_in(reservation.user) }

      before do
        ENV["HUGO_PACKET_BUCKET"] = "stub"
        ENV["HUGO_PACKET_PREFIX"] = "stub"
        Aws.config.update(stub_responses: true)
        Aws::S3::Client.new.stub_data(:list_objects_v2,
                                      prefix: "/",
                                      contents: [])
      end

      it "renders ok" do
        expect(get(:index)).to have_http_status(:ok)
      end
    end
  end

  describe "#show" do
    subject(:get_show) { get :show, params: { id: "harry-potter.zip" } }
    let(:s3_signed_url) { "https://www.wizardingworld.com/about-the-fan-club" }

    before do
      expect(Aws::S3::Object).to receive(:new).and_return(
        instance_double(Aws::S3::Object, presigned_url: s3_signed_url)
      )
    end

    let(:reservation) { create(:reservation, :with_claim_from_user, membership: adult) }
    let(:user) { reservation.user }
    before { sign_in(user) }

    it "increments our user's download counter" do
      expect { get_show }
        .to change { user.reload.hugo_download_counter }
        .by(1)
    end

    it "redirects us to s3" do
      expect(get_show).to redirect_to(s3_signed_url)
    end
  end
end
