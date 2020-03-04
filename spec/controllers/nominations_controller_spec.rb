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

  # Reset dates after tests run
  # pasta from config/initializers/hugo.rb
  after do
    SetHugoGlobals.new.call
  end

  describe "#show" do
    subject(:get_show) do
      get :show, params: { id: hugo.i18n_key, reservation_id: reservation.id }
    end

    it "404s when signed out" do
      expect { get_show }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "404s when you don't have nomination rights" do
      reservation.membership.update!(can_nominate: false)
      expect { get_show }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "when signed in" do
      before { sign_in(user) }

      context "when nominations are open" do
        before do
          $nomination_opens_at = 1.second.ago
          $voting_opens_at = 1.day.from_now
          $hugo_closed_at = 2.days.from_now
        end

        it "renders during nomination" do
          expect(get_show).to have_http_status(:ok)
          expect(response.body).to_not include(retro_best_novel.name)
        end

        it "redirects when you've not set your name" do
          reservation.active_claim.detail.destroy!
          expect(get_show).to have_http_status(:found)
          expect(flash[:notice]).to match(/enter your details/i)
        end

        context "when you're a Dublin member" do
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
              raise "couldn't upgrade membership" if !successful
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

          context "with hugo_admin rights" do
            let(:support) { create(:support, :hugo_admin) }

            it "renders ok" do
              expect(get_show).to have_http_status(:ok)
              expect(flash[:notice]).to be_nil
            end
          end
        end
      end

      it "doesn't render before nomination" do
        $nomination_opens_at = 1.day.from_now
        $voting_opens_at = 2.days.from_now
        $hugo_closed_at = 3.days.from_now
        expect { get_show }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "deosn't renderafter nomination" do
        $nomination_opens_at = 1.day.ago
        $voting_opens_at = 1.second.ago
        $hugo_closed_at = 1.day.from_now
        expect { get_show }.to raise_error(ActiveRecord::RecordNotFound)
      end

      context "when reservation is in instalment" do
        let!(:reservation) do
          create(:reservation,
            :instalment,
            :with_order_against_membership,
            :with_claim_from_user,
            instalment_paid: 0,
          )
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

  describe "#update" do
    subject(:post_update) do
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
              5 => empty_entry,
            }
          }
        },
      })
    end

    let(:filled_entry) do
      {
        field_1: "Leviathan Wakes",
        field_2: "James S. A. Corey",
        field_3: "Orbit Books",
      }
    end

    let(:partial_entry) do
      {
        field_1: "This Side of Paradise",
        field_2: "Ummm...",
        field_3: "",
      }
    end

    let(:empty_entry) do
      {
        field_1: "",
        field_2: "",
        field_3: "",
      }
    end

    context "when nominations are closed signed in as hugo admin" do
      let(:hugo_admin) { create(:support, :hugo_admin) }

      before { sign_in hugo_admin }

      it "renders ok" do
        expect(post_update).to have_http_status(:ok)
      end

      it "creates nominations" do
        expect { post_update }.to change { Nomination.count }.from(0)
      end

      it "has an audit trail" do
        expect { post_update }.to change { Note.count }.by(1)
        expect(Note.last.content).to include(hugo_admin.email)
        expect(Note.last.content).to match(/hugo admin/i)
      end
    end

    context "signed in with nominations open" do
      before { sign_in user }

      before do
        $nomination_opens_at = 1.second.ago
        $voting_opens_at = 1.day.from_now
        $hugo_closed_at = 2.days.from_now
      end

      context "when posting valid params" do
        it "renders ok" do
          expect(post_update).to have_http_status(:ok)
        end

        it "creates nominations" do
          expect { post_update }.to change { Nomination.count }.from(0)
        end
      end
    end
  end
end
