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

class SiteSelectionMailer < ApplicationMailer
  def bought_token(reservation:, voter_id:, token:, election_name:, election_info:)
    @worldcon_basic_greeting = worldcon_basic_greeting
    @worldcon_public_name = worldcon_public_name

    @contact = reservation.active_claim.contact
    @voter_id = voter_id
    @token = token
    @election_info = election_info
    @election_name = election_name

    mail(
      from: $site_selection_email,
      to: @contact.email,

      subject: "#{election_name} token purchased"
    )
  end
end
