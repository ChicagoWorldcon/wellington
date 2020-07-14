# frozen_string_literal: true

# Copyright 2019 Steven C Hartley
# Copyright 2020 Matthew B. Gray
# Copyright 2020 Victoria Garcia
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

class MembershipMailer < ApplicationMailer
  include ApplicationHelper
  default from: $member_services_email

  def login_link(token:, email:)
    @token = token
    @worldcon_public_name = worldcon_public_name
    @worldcon_greeting_sentence_excited = worldcon_greeting_sentence_excited
    @worldcon_homepage_url = worldcon_url_homepage
    mail(
      to: email,
      subject: "#{worldcon_public_name} Login Link for #{email}"
    )
  end

  def transfer(from:, to:, owner_name:, membership_number:)
    @worldcon_public_name = worldcon_public_name
    @worldcon_greeting_sentence_excited = worldcon_greeting_sentence_excited
    @worldcon_homepage_url = worldcon_url_homepage
    @from = from
    @to = to
    @owner_name = owner_name
    @membership_number = membership_number
    mail(
      to: [from, to],
      cc: $member_services_email,
      subject: "#{worldcon_public_name}: Transferred ##{membership_number} from #{from} to #{to}"
    )
  end
end
