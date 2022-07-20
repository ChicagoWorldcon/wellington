# frozen_string_literal: true

# Copyright 2022 Chris Rose
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

class SiteSelectionTokensController < ApplicationController
  before_action :lookup_reservation!

  def index
    @all_elections = SiteSelectionToken.elections
    @unclaimed_elections = @all_elections.reject do |e|
      owned_tokens = @reservation.site_selection_tokens
      owned_tokens.any? { |tok| tok.election == e }
    end
    @prices = Hash[@all_elections.map { |e| [e, t("rights.site_selection.#{e}.price").to_i] }]
  end
end
