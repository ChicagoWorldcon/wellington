# Copyright 2020 Matthew B. Gray
# Copyright 2020 Steven Ensslen
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

RSpec.describe GlooSync, type: :job do
  subject(:job) { described_class.new }
  let(:user) { create(:user) }

  # Enable Gloo integrations for this test
  # But turn it off after so CI doesn't try reaching out to thefantasy.network
  around do |test|
    ENV["GLOO_BASE_URL"] = "https://apitemp.thefantasy.network"
    ENV["GLOO_AUTHORIZATION_HEADER"] = "let_me_in_please"
    test.run
    ENV["GLOO_BASE_URL"] = nil
    ENV["GLOO_AUTHORIZATION_HEADER"] = nil
  end


  describe "#perform" do
    context "when service down" do
      after do
        # Basically rely on sidekiq to add this to the retry queue
        expect { job.perform(user.email) }.to raise_error("service down")
      end

      it "raises error if get has 500" do
        expect(HTTParty).to receive(:get).and_return(service_down)
      end

      it "raises error if get roles has 500" do
        expect(HTTParty).to receive(:get).and_return(lookup_user_found)
        expect(HTTParty).to receive(:get).and_return(service_down)
      end

      it "raises error if post has 500" do
        expect(HTTParty).to receive(:get).and_return(lookup_user_found)
        expect(HTTParty).to receive(:get).and_return(roles_moderator)
        expect(HTTParty).to receive(:post).and_return(service_down)
      end
    end

    context "after run" do
      after { job.perform(user.email) }

      it "looks up user, then roles, then posts back to user" do
        expect(HTTParty).to receive(:get).with(%r{/v1/users/.*}, any_args).and_return(lookup_user_found)
        expect(HTTParty).to receive(:get).with(%r{/v1/users/.*/roles}, any_args).and_return(roles_moderator)
        expect(HTTParty).to receive(:post).with(%r{/v1/users$}, any_args).and_return(post_success)
      end

      it "doesn't look up roles if user is missing" do
        expect(HTTParty).to receive(:get).with(%r{/v1/users/.*}, any_args).and_return(lookup_user_missing)
        expect(HTTParty).to receive(:post).with(%r{/v1/users$}, any_args).and_return(post_success)
      end

      it "updates rights to [] if user can't attend and didn't exist" do
        expect(HTTParty).to receive(:get).and_return(lookup_user_missing)
        expect(HTTParty).to receive(:post).with(any_args, hash_including(body: /.*"roles":\[\].*/)).and_return(post_success)
      end

      it "non attending members don't lose moderator access" do
        expect(HTTParty).to receive(:get).and_return(lookup_user_found)
        expect(HTTParty).to receive(:get).and_return(roles_moderator)
        expect(HTTParty).to receive(:post).with(any_args, hash_including(body: /.*moderator.*/)).and_return(post_success)
      end

      it "updates rights with video if user can attend" do
        create(:reservation, membership: adult, user: user)
        expect(HTTParty).to receive(:get).and_return(lookup_user_missing)
        expect(HTTParty).to receive(:post).with(any_args, hash_including(body: /.*video.*/)).and_return(post_success)
      end

      described_class.new.perform(user.email)
    end
  end
end
