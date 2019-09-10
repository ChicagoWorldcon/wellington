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

# Preview all emails at http://localhost:3000/rails/mailers/membership_mailer
class MembershipMailerPreview < ActionMailer::Preview
  def login_link
    MembershipMailer.login_link(
      email: Faker::Internet.email,
      token: JWT.encode({data: "stub"}, "secret", "HS256")
    )
  end

  def transfer
    reservation = Reservation.last(30).sample

    MembershipMailer.transfer(
      from: Faker::Internet.email,
      to: Faker::Internet.email,
      owner_name: reservation.active_claim.detail.to_s,
      membership_number: reservation.membership_number,
    )
  end
end
