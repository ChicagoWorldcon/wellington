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

RSpec.describe LoginToken do
  let(:good_secret) { "you'll never find the treasure" }
  let(:good_email) { "willy_wönka@chocolate_factory.nz" }
  let(:user) { create(:user) }

  subject(:model) { LoginToken.new(email: good_email, secret: good_secret) }
  it { is_expected.to be_valid }

  context "missing secret" do
    subject(:model) { LoginToken.new(email: good_email, secret: "") }
    it { is_expected.to_not be_valid }
  end

  context "missing email" do
    subject(:model) { LoginToken.new(email: "", secret: good_secret) }
    it { is_expected.to_not be_valid }
  end

  context "with bad email" do
    subject(:model) { LoginToken.new(email: "not @good.net", secret: good_secret) }
    it { is_expected.to_not be_valid }
  end

  describe "#encode" do
    let(:secret) { "flubber" }
    let(:model) { LoginToken.new(email: user.email, secret: secret) }

    subject(:encoded_token) { model.encode }
    it { is_expected.to_not be_nil }

    context "when used with LoginToken#decode_and_lookup!" do
      it "finds the original user" do
        expect(LoginToken.decode_and_lookup!(secret, jwt_token: encoded_token)).to eq(user)
      end
    end
  end

  describe "LoginToken#decode_and_lookup!" do
    let(:secret) { "flubber" }
    let(:encoded_token) { JWT.encode(login_info, secret, "HS256") }

    context "with expired token" do
      let(:login_info) do
        {
          exp: 1.second.ago.to_i,
          email: user.email,
        }
      end

      it "raises exception" do
        expect { LoginToken.decode_and_lookup!(secret, jwt_token: encoded_token) }.to raise_error(JWT::ExpiredSignature)
      end
    end

    context "with unfound user" do
      let(:login_info) do
        {
          exp: 10.seconds.from_now.to_i,
          email: "never gonna give you up",
        }
      end

      it "returns nil" do
        expect(LoginToken.decode_and_lookup!(secret, jwt_token: encoded_token)).to be_nil
      end
    end

    context "with credentials of legit user" do
      let(:login_info) do
        {
          exp: 10.seconds.from_now.to_i,
          email: user.email,
        }
      end

      it "returns nil" do
        expect(LoginToken.decode_and_lookup!(secret, jwt_token: encoded_token)).to eq(user)
      end
    end
  end
end
