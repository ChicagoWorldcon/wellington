# frozen_string_literal: true

require "spec_helper"

RSpec.describe BuildPersonRow do
  let(:person) { build(:person) }

  subject(:service) { BuildPersonRow.new(person) }

  describe "#to_row" do
    context "with errors on the person" do
      context "missing a payment" do
        before do
          expect(service).to receive(:payment).and_return(nil)
        end

        it "raises an error" do
          expect { service.to_row }.to raise_error(BuildPersonRow::ExportError, /is missing a payment/)
        end
      end

      context "payment membership does not match persons" do
        let(:person) { build(:person, membership: "Adult") }
        let(:mismatching_payment) { build(:payment, type: "Child") }

        before do
          allow(service).to receive(:payment).and_return(mismatching_payment)
        end

        it "raises an error" do
          expect { service.to_row }.to raise_error(BuildPersonRow::ExportError, /payment does not match membership/)
        end
      end
    end

    context "with valid data" do
      let(:person) { build(:person, id: 421) }
      let(:payment) { build(:payment) }

      before do
        allow(service).to receive(:payment).and_return(payment)
      end

      it "exports the row" do
        expect(service.to_row).to match_array [
          person.legal_name,
          person.public_first_name,
          person.public_last_name,
          person.badge_name,
          person.badge_subtitle,
          person.city,
          person.state,
          person.country,
          person.email,
          "Imported from kansa. People##{person.id}",
          person.membership,
          payment.stripe_charge_id,
          payment.amount,
          "kansa payment##{payment.id} for #{payment.amount.to_f / 100}#{payment.currency.upcase} paid with token #{payment.stripe_token} for #{payment.type} (#{payment.category})",
          person.member_number
        ]
      end
    end
  end
end
