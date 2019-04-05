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

RSpec.describe Token::SendLink do
  let(:good_email) { Faker::Internet.email }
  let(:good_secret) { "you'll never find the treasure" }
  let(:good_path) { "/purchases" }
  let(:query) { Token::SendLink.new(email: good_email, secret: good_secret) }

  describe "#call" do
    it "sends email" do
      service = Token::SendLink.new(email: good_email, secret: good_secret)
      expect(MembershipMailer).to receive_message_chain(:login_link, :deliver_later).and_return(true)
      expect(service.call).to be_truthy
    end

    it "sends email with good path" do
      service = Token::SendLink.new(email: good_email, secret: good_secret, path: good_path)
      expect(MembershipMailer).to receive_message_chain(:login_link, :deliver_later).and_return(true)
      expect(service.call).to be_truthy
    end

    it "sends email with blank path" do
      service = Token::SendLink.new(email: good_email, secret: good_secret, path: "")
      expect(MembershipMailer).to receive_message_chain(:login_link, :deliver_later).and_return(true)
      expect(service.call).to be_truthy
    end

    context "with invalid inptus" do
      before { expect(MembershipMailer).to_not receive(:login_link) }

      it "fails with bad email" do
        [
          Token::SendLink.new(email: "", secret: good_secret),
          Token::SendLink.new(email: "hax0r", secret: good_secret),
        ].each do |service|
          expect(service.call).to be_falsey
          expect(service.errors).to include(/email/i)
        end
      end

      it "fails with missing secret" do
        service = Token::SendLink.new(email: good_email, secret: "")
        expect(service.call).to be_falsey
        expect(service.errors).to include(/secret/i)
      end

      it "reports errors when JWT encode fails" do
        expect(JWT).to receive(:encode).and_raise(JWT::EncodeError)
        service = Token::SendLink.new(email: good_email, secret: good_secret)
        expect(service.call).to be_falsey
        expect(service.errors).to include(/jwt/i)
      end
    end
  end
end
