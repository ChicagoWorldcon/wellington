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

RSpec.describe GlooContact do
  let(:user) { reservation.user }
  let(:reservation) { create(:reservation, :with_order_against_membership, :with_claim_from_user) }
  let(:query) { described_class.new(user) }

  # Enable Gloo integrations for this test
  # But turn it off after so CI doesn't try reaching out to thefantasy.network
  around do |test|
    ENV["GLOO_BASE_URL"] = "https://apitemp.thefantasy.network"
    ENV["GLOO_AUTHORIZATION_HEADER"] = "let_me_in_please"
    test.run
    ENV["GLOO_BASE_URL"] = nil
    ENV["GLOO_AUTHORIZATION_HEADER"] = nil
  end

  let(:user_found_response) do
    instance_double(HTTParty::Response,
      code: 200,
      body: {
        id: "42",
        email: user.email,
        name: "Superman",
        display_name: "Clark Kent",
        expiration: nil,
      }.to_json,
    )
  end

  let(:user_missing_response) do
    instance_double(HTTParty::Response,
      code: 404,
      body: %{
        <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
        <title>404 Not Found</title>
        <h1>Not Found</h1>
        <p>The requested URL was not found on the server. If you entered the URL manually please check your spelling and try again.</p>
      }.strip_heredoc,
    )
  end

  let(:remote_roles) do
    [
      "Discord_ServerMod",
      "Discord_PlatMod",
      "Discord_Experience_support",
      "Discord_ConCom",
      "Discord_Mission_Control",
      "Discord_Tech_staff",
      "Discord_Staff",
      "Discord_Crew",
    ]
  end

  let(:user_roles_response) do
    instance_double(HTTParty::Response,
      code: 200,
      body: { roles: remote_roles }.to_json,
    )
  end

  let(:post_success) do
    instance_double(HTTParty::Response,
      code: 200,
      body: { status: "ok" }.to_json,
    )
  end

  # This happens a lot
  # So we we should be able to handle when this happens
  let(:service_down_response) do
    instance_double(HTTParty::Response,
      code: 503,
      body: %{
        <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
        <html><head>
        <title>503 Service Unavailable</title>
        </head><body>
        <h1>Service Unavailable</h1>
        <p>The server is temporarily unable to service your
        request due to maintenance downtime or capacity
        problems. Please try again later.</p>
        <hr>
        <address>Apache Server at apitemp.thefantasy.network Port 443</address>
        </body></html>
      }.strip_heredoc,
    )
  end

  describe "#remote_state" do
    subject(:remote_state) { query.remote_state }

    it "is an empty hash when remote user responds 404" do
      expect(HTTParty).to receive(:get).with(%r{/v1/users/.*}, any_args).and_return(user_missing_response)
      expect(HTTParty).to receive(:get).with(%r{/v1/users/.*/roles}, any_args).and_return(user_missing_response)
      expect(remote_state).to be_kind_of(Hash)
      expect(remote_state).to be_empty
    end

    context "with service up and user available" do
      before do
        expect(HTTParty).to receive(:get).with(%r{/v1/users/.*}, any_args).and_return(user_found_response)
        expect(HTTParty).to receive(:get).with(%r{/v1/users/.*/roles}, any_args).and_return(user_roles_response)
      end

      it { is_expected.to be_kind_of(Hash) }
      it { is_expected.to_not be_empty }

      it "lists remote roles in a single object" do
        expect(remote_state[:roles]).to_not be_empty
        expect(remote_state[:roles]).to include(remote_roles.first)
        expect(remote_state[:roles]).to include(remote_roles.last)
      end

      it "lists a user's properties on the response" do
        expect(remote_state).to_not be_empty
        expect(remote_state[:email]).to eq(user.email)
        expect(remote_state[:name]).to be_present
        expect(remote_state[:display_name]).to be_present
      end
    end

    context "when service goes down" do
      after do
        expect { remote_state }.to raise_error(GlooContact::ServiceUnavailable)
      end

      it "raises when user lookup explodes" do
        expect(HTTParty).to receive(:get).with(%r{/v1/users/.*}, any_args).and_return(service_down_response)
      end

      it "raises for missing roles" do
        expect(HTTParty).to receive(:get).with(%r{/v1/users/.*}, any_args).and_return(user_found_response)
        expect(HTTParty).to receive(:get).with(%r{/v1/users/.*/roles}, any_args).and_return(service_down_response)
      end

      it "raises for socket errors" do
        expect(HTTParty).to receive(:get).with(%r{/v1/users/.*}, any_args).and_raise(SocketError)
      end
    end
  end

  describe "#local_state" do
    subject(:local_state) { query.local_state }

    context "when no roles on remote" do
      before do
        expect(HTTParty).to receive(:get).with(%r{/v1/users/.*}, any_args).and_return(user_missing_response)
        expect(HTTParty).to receive(:get).with(%r{/v1/users/.*/roles}, any_args).and_return(user_missing_response)
      end

      it { is_expected.to be_kind_of(Hash) }
      it { is_expected.to_not be_empty }

      it "has the local user's id" do
        expect(local_state[:id]).to be_kind_of(String) # always be careful with types of IDs
        expect(local_state[:id]).to eq(user.id.to_s)
      end

      it "uses the local user's name" do
        expect(local_state[:name]).to eq(ConzealandContact.last.to_s)
        expect(local_state[:display_name]).to eq(ConzealandContact.last.badge_display)
      end

      it "defaults to blank strings when contact is not available" do
        ConzealandContact.where(claim_id: user.claims).destroy_all
        expect(local_state[:name]).to be_blank
        expect(local_state[:display_name]).to be_blank
      end

      describe "roles listed" do
        subject(:roles) { local_state[:roles] }

        let(:adult) { create(:membership, :adult) }
        let(:supporting) { create(:membership, :supporting) }
        let(:kiwi) { create(:membership, :kiwi) }
        let(:community_sponsor) { create(:membership, :community_sponsor) }
        let(:community_press_pass) { create(:membership, :community_press_pass) }

        context "for adult reservations" do
          let(:reservation) { create(:reservation, :with_claim_from_user, membership: adult) }
          it { is_expected.to include(GlooContact::MEMBER_VOTING) }
          it { is_expected.to include(GlooContact::MEMBER_ATTENDING) }
          it { is_expected.to include(GlooContact::MEMBER_HUGO) }
        end

        context "for supporting reservations" do
          let(:reservation) { create(:reservation, :with_claim_from_user, membership: supporting) }
          it { is_expected.to include(GlooContact::MEMBER_VOTING) }
          it { is_expected.to_not include(GlooContact::MEMBER_ATTENDING) }
          it { is_expected.to_not include(GlooContact::MEMBER_HUGO) }
        end

        context "for kiwi reservations" do
          let(:reservation) { create(:reservation, :with_claim_from_user, membership: kiwi) }
          it { is_expected.to_not include(GlooContact::MEMBER_VOTING) }
          it { is_expected.to_not include(GlooContact::MEMBER_ATTENDING) }
          it { is_expected.to_not include(GlooContact::MEMBER_HUGO) }
        end

        context "for community sponsor" do
          let(:reservation) { create(:reservation, :with_claim_from_user, membership: community_sponsor) }
          it { is_expected.to_not include(GlooContact::MEMBER_VOTING) }
          it { is_expected.to_not include(GlooContact::MEMBER_ATTENDING) }
          it { is_expected.to include(GlooContact::MEMBER_HUGO) }
        end
      end
    end

    context "when adult attending with roles on remote" do
      let(:adult) { create(:membership, :adult) }
      let(:reservation) { create(:reservation, :with_claim_from_user, membership: adult) }

      before do
        expect(HTTParty).to receive(:get).with(%r{/v1/users/.*}, any_args).and_return(user_found_response)
        expect(HTTParty).to receive(:get).with(%r{/v1/users/.*/roles}, any_args).and_return(user_roles_response)
      end

      subject(:roles) { local_state[:roles] }

      it { is_expected.to_not be_empty }
      it { is_expected.to include(GlooContact::MEMBER_ATTENDING) }
      it { is_expected.to include(remote_roles.last) }
      it { is_expected.to include(remote_roles.first) }
    end

    context "integration" do
      before do
        allow(HTTParty).to receive(:get).with(%r{/v1/users/.*}, any_args).and_return(user_missing_response)
        allow(HTTParty).to receive(:get).with(%r{/v1/users/.*/roles}, any_args).and_return(user_missing_response)
      end

      it "cycles memberships on transfer" do
        user = create(:user)
        adult = create(:membership, :adult)
        last_minute_decision = create(:reservation, user: user, created_at: 1.day.ago, membership: adult)
        create(:conzealand_contact, first_name: "last minute decision", claim: last_minute_decision.active_claim)

        early_bird_reservation = create(:reservation, user: user, created_at: 365.days.ago, membership: adult)
        create(:conzealand_contact, first_name: "early bird price", claim: early_bird_reservation.active_claim)
        result = described_class.new(user).local_state
        expect(result[:display_name]).to match(/early bird price/)
        expect(result[:roles]).to include("M_Attending")

        ApplyTransfer.new(early_bird_reservation, from: user, to: create(:user), audit_by: "agile squirrel").call
        result = described_class.new(user.reload).local_state
        expect(result[:display_name]).to match(/last minute decision/)
        expect(result[:roles]).to include("M_Attending")

        ApplyTransfer.new(last_minute_decision, from: user, to: create(:user), audit_by: "agile squirrel").call
        result = described_class.new(user.reload).local_state
        expect(result[:display_name]).to be_empty
        expect(result[:roles]).to be_empty
      end
    end
  end

  describe "#discord_roles" do
    before do
      expect(HTTParty).to receive(:get).with(%r{/v1/users/.*}, any_args).and_return(user_found_response)
      expect(HTTParty).to receive(:get).with(%r{/v1/users/.*/roles}, any_args).and_return(user_roles_response)
    end

    context "with remote roles" do
      it "removes those roles when we set to empty" do
        expect { query.discord_roles = [] }
          .to change { query.discord_roles }
          .from(remote_roles).to be_empty
      end
    end

    context "when no roles are on remote" do
      let(:remote_roles) { [] }

      it "adds roles when we set them" do
        expect { query.discord_roles = ["Discord_PlatMod"] }
          .to change { query.discord_roles }
          .from([]).to(["Discord_PlatMod"])
      end

      it "doesn't let you set roles not defined in GlooContact::DISCORD_ROLES" do
        expect { query.discord_roles = ["Party_Time"] }
          .to_not change { query.discord_roles }.from([])
      end
    end
  end

  describe "#save!" do
    subject(:save!) { query.save! }

    before do
      expect(HTTParty).to receive(:get).with(%r{/v1/users/.*}, any_args).and_return(user_missing_response)
      expect(HTTParty).to receive(:get).with(%r{/v1/users/.*/roles}, any_args).and_return(user_missing_response)
    end

    it "doesn't raise when successful" do
      expect(HTTParty).to receive(:post).with(any_args).and_return(post_success)
      save!
    end

    it "raises error when server is down" do
      expect(HTTParty).to receive(:post).with(any_args).and_return(service_down_response)
      expect { save! }.to raise_error(GlooContact::ServiceUnavailable)
    end
  end
end
