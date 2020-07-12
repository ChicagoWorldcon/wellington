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
  let(:adult) { create(:membership, :adult) }

  # Enable Gloo integrations for this test
  # But turn it off after so CI doesn't try reaching out to thefantasy.network
  around do |test|
    ENV["GLOO_BASE_URL"] = "https://apitemp.thefantasy.network"
    ENV["GLOO_AUTHORIZATION_HEADER"] = "let_me_in_please"
    test.run
    ENV["GLOO_BASE_URL"] = nil
    ENV["GLOO_AUTHORIZATION_HEADER"] = nil
  end
end
