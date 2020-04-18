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

RSpec.describe NominationsController, type: :controller do
  render_views

  let!(:hugo) { create(:election) }
  let!(:best_novel) { create(:category, :best_novel, election: hugo) }
  let!(:best_series) { create(:category, :best_series, election: hugo) }
  let!(:retro_hugo) { create(:election, :retro) }
  let!(:retro_best_novel) { create(:category, :retro_best_novel, election: retro_hugo) }

  let(:reservation) { create(:reservation, :with_order_against_membership, :with_claim_from_user) }
  let(:user) { reservation.user }

  describe "#show" do
    subject(:get_show) do
      get :show, params: { id: hugo.i18n_key, reservation_id: reservation.id }
    end

    it "404s when signed out" do
      expect(HugoState).to_not receive(:new)
      expect { get_show }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "when signed in with hugo_admin rights" do
      it "renders ok" do
        sign_in create(:support, :hugo_admin)
        expect(HugoState).to_not receive(:new)
        expect(get_show).to have_http_status(:ok)
        expect(flash[:notice]).to be_nil
      end
    end

    context "when nominations are closed" do
      before do
        expect(HugoState)
          .to receive_message_chain(:new, :has_nominations_opened?)
          .and_return(false)
      end

      context "when signed in" do
        before { sign_in(user) }

        it "redirects with notice" do
          expect(get_show).to redirect_to(reservation_path(reservation))
          expect(flash[:notice]).to include("nominations are closed")
        end
      end
    end

    context "when nominations are open" do
      before do
        expect(HugoState)
          .to receive_message_chain(:new, :has_nominations_opened?)
          .and_return(true)
      end

      context "when signed in" do
        before { sign_in(user) }

        it "renders categories on that page only" do
          expect(get_show).to have_http_status(:ok)
          expect(response.body).to_not include(retro_best_novel.name)
        end

        it "redirects with notice when you don't have nomination rights" do
          reservation.membership.update!(can_nominate: false)
          expect(get_show).to redirect_to(reservation_path(reservation))
          expect(flash[:notice]).to match(/nomination rights/i)
        end

        it "redirects when you've not set your name" do
          reservation.active_claim.detail.destroy!
          expect(get_show).to have_http_status(:found)
          expect(flash[:notice]).to match(/enter your details/i)
        end

        context "as Dublin member" do
          let(:dublin) { create(:membership, :dublin_2019) }
          let(:reservation) { create(:reservation, :with_claim_from_user, membership: dublin) }

          it "doesn't redirect if you're a dublin member" do
            reservation.active_claim.detail.destroy!
            expect(get_show).to have_http_status(:ok)
          end

          context "and you upgrade to Supporting after nominations close" do
            let(:reservation) { create(:reservation, :with_claim_from_user, membership: dublin) }
            let(:supporting_without_nomination) { create(:membership, :supporting, can_nominate: false) }

            before do
              upgrader = UpgradeMembership.new(reservation, to: supporting_without_nomination)
              successful = upgrader.call
              raise "couldn't upgrade membership" unless successful
            end

            it "forces the user to enter their details" do
              reservation.active_claim.detail.destroy!
              expect(get_show).to_not have_http_status(:ok)
              expect(flash[:notice]).to match(/enter your details/)
            end

            it "renders the form when you have details entered" do
              expect(get_show).to have_http_status(:ok)
            end
          end
        end

        context "when signed in as support" do
          let(:support) { create(:support) }

          before { sign_in support }

          it "redirects, doesn't let you look at the nomination" do
            expect(get_show).to have_http_status(:found)
            expect(flash[:notice]).to match(/signed in as support/i)
          end
        end

        context "with reservation in instalment" do
          let!(:reservation) do
            create(:reservation,
                   :instalment,
                   :with_order_against_membership,
                   :with_claim_from_user,
                   instalment_paid: 0)
          end

          it "redirects when there's no payments on a membership" do
            expect(reservation.reload.has_paid_supporting?).to be_falsey
            expect(get_show).to have_http_status(:found)
            expect(flash[:error]).to be_present
          end

          it "dispays when a user has paid for a supporting membership" do
            reservation.charges << create(:charge, user: reservation.user)
            expect(reservation.reload.has_paid_supporting?).to be_truthy
            expect(get_show).to have_http_status(:ok)
          end
        end
      end
    end
  end

  describe "#update" do
    subject(:put_update) do
      put(:update, params: {
            id: hugo.i18n_key,
            reservation_id: reservation.id,
            category_id: best_novel.id,
            category: {
              best_novel.id => {
                nomination: {
                  1 => filled_entry,
                  2 => partial_entry,
                  3 => empty_entry,
                  4 => empty_entry,
                  5 => empty_entry
                }
              }
            }
          })
    end

    let(:filled_entry) do
      {
        field_1: "Leviathan Wakes",
        field_2: "James S. A. Corey",
        field_3: "Orbit Books"
      }
    end

    let(:partial_entry) do
      {
        field_1: "This Side of Paradise",
        field_2: "Ummm...",
        field_3: ""
      }
    end

    let(:empty_entry) do
      {
        field_1: "",
        field_2: "",
        field_3: ""
      }
    end

    context "signed in as hugo admin" do
      let(:hugo_admin) { create(:support, :hugo_admin) }

      before { sign_in hugo_admin }

      it "renders without checking HugoState" do
        expect(HugoState).to_not receive(:new)
        expect(put_update).to have_http_status(:ok)
      end

      it "creates nominations" do
        expect { put_update }.to change { Nomination.count }.from(0)
      end

      it "has an audit trail" do
        expect { put_update }.to change { Note.count }.by(1)
        expect(Note.last.content).to include(hugo_admin.email)
        expect(Note.last.content).to match(/hugo admin/i)
      end
    end

    context "with nominations open" do
      before do
        expect(HugoState)
          .to receive_message_chain(:new, :has_nominations_opened?)
          .and_return(true)
      end

      before { sign_in(user) }

      it "renders ok" do
        expect(put_update).to have_http_status(:ok)
      end

      it "creates nominations" do
        expect { put_update }.to change { Nomination.count }.from(0)
      end
    end
  end
end
