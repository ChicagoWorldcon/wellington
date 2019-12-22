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
require "csv"

RSpec.describe Import::DublinMembers do
  let(:data) { "" }
  let(:read_stream) { StringIO.new(data) }
  let(:description) { "test stream" }
  subject(:command) { described_class.new(read_stream, description) }

  describe "#call" do
    subject(:call) { command.call }

    it { is_expected.to be_truthy }

    it "imports nothing when the file is empty" do
      expect { call }.to_not change { Membership.count }
      expect(command.errors).to be_empty
    end

    context "when the headings are wrong" do
      let(:data) do
        CSV.generate do |csv|
          csv << %w(it's the wrong trowsers gromit!)
        end
      end

      it { is_expected.to be_falsey }
    end
  end
end
