require "rails_helper"

RSpec.describe TokenPurchaseController, type: :controller do
  let!(:adult) { create(:membership, :adult) }
  let!(:existing_reservation) { create(:reservation, :with_claim_from_user, membership: adult) }
  let!(:original_user) { existing_reservation.user }
  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:token) { stripe_helper.generate_card_token }

  before do
    sign_in(original_user)
    StripeMock.start
  end

  after { StripeMock.stop }

  describe "#create" do
    context "when no tokens are available" do
      let(:params) do
        {
          reservation_id: existing_reservation.id,
          election: "worldcon",
          stripeEmail: existing_reservation.active_claim.contact.email,
          stripeToken: token
        }
      end

      it "flashes an error" do
        post :create, params: params
        expect(flash[:error]).to match(/No tokens/)
      end

      it "redirects to the token page" do
        post :create, params: params
        expect(response).to redirect_to(reservation_site_selection_tokens_path(existing_reservation))
      end
    end

    context "when there are tokens available" do
      let!(:site_selection_token) { create(:site_selection_token) }
      let(:params) do
        {
          reservation_id: existing_reservation.id,
          election: site_selection_token.election,
          stripeEmail: existing_reservation.active_claim.contact.email,
          stripeToken: token
        }
      end

      it "redirects to the token page" do
        post :create, params: params
        expect(response).to redirect_to(reservation_site_selection_tokens_path(existing_reservation))
      end

      it "flashes no errors" do
        post :create, params: params
        expect(flash[:error]).to_not be_present
      end

      it "decreases the number of unclaimed tokens" do
        expect { post :create, params: params }.to change {
                                                     SiteSelectionToken.unclaimed.count
                                                   }.by(-1)
      end

      it "increases the number of tokens owned by the reservation" do
        expect { post :create, params: params }.to change {
          existing_reservation.site_selection_tokens.count
        }.by(1)
      end

      context "but a token is already owned" do
        let(:next_token) do
          SiteSelectionToken.create!(election: site_selection_token.election, voter_id: "vid 2", token: "token 2")
        end
        before do
          @purchase = TokenPurchase.for_election!(existing_reservation, site_selection_token.election)
          @purchase.charge_stripe!(charge_id: "fake ID", price_cents: 40_00)
        end

        it "should already have a token" do
          expect(existing_reservation.site_selection_tokens.count).to be(1)
        end

        it "flashes an error" do
          post :create, params: params
          expect(flash[:error]).to match(/more than one/)
        end

        it "redirects to the token page" do
          post :create, params: params
          expect(response).to redirect_to(reservation_site_selection_tokens_path(existing_reservation))
        end

        it "does not decrease the number of unclaimed tokens" do
          expect { post :create, params: params }.to_not change {
                                                           SiteSelectionToken.unclaimed.count
                                                         }
        end

        it "does not increase the number of tokens owned by the reservation" do
          expect { post :create, params: params }.to_not change {
            existing_reservation.site_selection_tokens.count
          }
        end
      end
    end
  end
end
