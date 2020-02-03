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

RSpec.describe MergeMembership do
  let(:us) { create(:user) }
  let(:them) { create(:user) }

  let(:adult) { create(:membership, :adult) }
  let(:supporting) { create(:membership, :supporting) }

  let(:reservation_1) { create(:reservation, membership: adult) }
  let(:reservation_2) { create(:reservation, membership: adult) }

  subject(:command) { described_class.new([reservation_1, reservation_2]) }

  describe "#call" do
    subject(:call) { command.call }

    let(:reservation_1) { create(:reservation, user: us, membership: adult) }
    let(:reservation_2) { create(:reservation, user: us, membership: adult) }

    before do
      reservation_1.active_claim.update!(active_from: 1.day.ago)
      reservation_2.active_claim.update!(active_from: 1.day.ago)
    end

    it { is_expected.to be_truthy }

    it "doesn't have errors" do
      expect { call }.to_not change { command.errors.count }.from(0)
    end

    it "removes one membership from us" do
      expect { call }
        .to change { us.reservations.count }
        .by(-1)
    end

    it "fails when less or more than 2 memberships " do
      command = described_class.new([reservation_1])
      expect(command.call).to be_falsey
      expect(command.errors).to include(/2 memberships/i)

      command = described_class.new([reservation_1, reservation_1, reservation_1])
      expect(command.call).to be_falsey
      expect(command.errors).to include(/2 memberships/i)
    end

    context "when we reorder the content" do
      let!(:reservation_1) { create(:reservation, user: us, membership: adult) }
      let!(:reservation_2) { create(:reservation, user: us, membership: supporting) }

      it "keeps the higher priced thing" do
        expect { command.call }.to change { us.reload.reservations.count }.to(1)
        expect(us.reservations.last.membership).to eq(adult)
      end

      context "backwards" do
        let!(:reservation_1) { create(:reservation, user: us, membership: supporting) }
        let!(:reservation_2) { create(:reservation, user: us, membership: adult) }

        it "keeps the higher priced thing" do
          expect { command.call }.to change { us.reload.reservations.count }.to(1)
          expect(us.reservations.last.membership).to eq(adult)
        end
      end
    end

    it "always keeps the membership with the higher price" do
      first = MergeMembership.new([
        create(:reservation, user: us, membership: adult),
        create(:reservation, user: us, membership: supporting),
      ])

      # Hack to work around subsecond create/merge cycles
      first.reservations.each { |r| r.active_claim.update!(active_from: 5.minutes.ago) }

      expect { first.call }.to change { us.reload.reservations.count }.by(-1)
      expect(us.reservations.first.membership).to eq(adult)

      second = MergeMembership.new([
        create(:reservation, user: them, membership: supporting),
        create(:reservation, user: them, membership: adult),
      ])

      # Hack to work around subsecond create/merge cycles
      second.reservations.each { |r| r.active_claim.update!(active_from: 5.minutes.ago) }

      expect { second.call }.to change { them.reload.reservations.count }.by(-1)
      expect(them.reservations.first.membership).to eq(adult)
    end

    context "when owned by differnet people" do
      let(:reservation_1) { create(:reservation, user: us, membership: adult) }
      let(:reservation_2) { create(:reservation, user: them, membership: adult) }

      it { is_expected.to be_falsey }

      it "mentions context in it's errors" do
        expect { call }.to change { command.errors }.to include(/owned by the same user/i)
      end
    end

    xcontext "when there are nominations" do
      let(:best_novel) { create(:category, :best_novel) }
      let(:best_novella) { create(:category, :best_novella) }

      before do
        create(:nomination, reservation: reservation_1, category: best_novel)
        create(:nomination, reservation: reservation_1, category: best_novella)
        create(:nomination, reservation: reservation_2, category: best_novel)
        create(:nomination, reservation: reservation_2, category: best_novella)
      end

      it "transfers all nominations to the same user" do
        expect { call }
          .to change { reservation_1.reload.nominations.count }
          .from(2).to(4)
      end
    end
  end
end
