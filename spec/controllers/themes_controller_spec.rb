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

RSpec.describe ThemesController, type: :controller do
  render_views # we want all views to be viewable in the list

  describe "#index" do
    it "renders ok" do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#show" do
    it "renders ok" do
      get :show, params: { id: :conzealand }
      expect(response).to have_http_status(:ok)
    end
  end
end
