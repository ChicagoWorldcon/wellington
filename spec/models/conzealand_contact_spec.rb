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

RSpec.describe ConzealandContact, type: :model do
  TestContact = Struct.new(:contact, :expected_output)

  subject(:model) { create(:conzealand_contact, :with_claim) }
  it { is_expected.to be_valid }

  it "is valid to miss out some fields when it's for import" do
    model = build(:conzealand_contact, :with_claim, country: nil, address_line_1: nil)
    expect(model).to_not be_valid
    expect(model.as_import).to be_valid
  end

  describe "#to_s" do
    let(:tests) do
      [
        TestContact.new(
          described_class.new(
            first_name: "Spongebob",
            preferred_first_name: "Dr", preferred_last_name: "Who"
          ),
          "Dr Who",
        ),
        TestContact.new(
          described_class.new(
            first_name: "Spongebob",
            preferred_last_name: "Who?"
          ),
          "Who?",
        ),
        TestContact.new(
          described_class.new(first_name: "Spongebob"),
          "Spongebob",
        ),
        TestContact.new(
          described_class.new(title: "Dr", first_name: "Spongebob", last_name: "Squarepants"),
          "Dr Spongebob Squarepants",
        ),
      ]
    end

    it "uses firstname lastname if present, otherwise falls back to legal name" do
      tests.each do |test|
        expect(test.contact.to_s).to eq(test.expected_output)
      end
    end
  end

  describe "#badge_display" do
    it "combines badge title and subtitle if present" do
      expect(described_class.new(badge_title: "excellent").badge_display).to eq "excellent"
      expect(described_class.new(badge_subtitle: "excellent").badge_display).to eq "excellent"

      model = described_class.new(badge_title: "excellent", badge_subtitle: "sausage")
      expect(model.badge_display).to eq "excellent: sausage"
    end

    it "uses display name if badge title and subtitle not present" do
      model = build(:conzealand_contact, badge_title: "", badge_subtitle: "")
      expect(model.badge_display).to eq(model.to_s)
    end
  end

  # If this is failing
  # And CoNZealand is no longer running
  # Please feel free to backspace this entire block
  context "after #sync_with_gloo called" do
    # it's an after_commit hook, so executes after save
    after { create(:conzealand_contact, :with_claim) }

    # Tidy up after this spec
    around do |test|
      old_value = ENV["GLOO_BASE_URL"]
      test.run
      ENV["GLOO_BASE_URL"] = old_value
    end

    it "dosn't call GlooSync outside of conzealand" do
      Rails.configuration.contact_model = "dc"
      ENV["GLOO_BASE_URL"] = "https://api.thefantasy.network/v1"
      expect(GlooSync).to_not receive(:perform_async)
    end

    it "doesn't call GlooSync when not configured" do
      Rails.configuration.contact_model = "conzealand"
      ENV["GLOO_BASE_URL"] = nil
      expect(GlooSync).to_not receive(:perform_async)
    end

    it "calls when confgured in conzealand" do
      Rails.configuration.contact_model = "conzealand"
      ENV["GLOO_BASE_URL"] = "https://api.thefantasy.network/v1"
      expect(GlooSync).to receive(:perform_async).at_least(:once)
    end
  end
end
