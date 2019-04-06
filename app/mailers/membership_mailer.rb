# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2019 Steven C Hartley
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
class MembershipMailer < ApplicationMailer
  default from: ENV["EMAIL_PAYMENTS"]

  def login_link(token:, email:)
    @token = token
    mail(to: email, subject: "CoNZealand Login Link for #{email}") do |format|
      #text must be called before html.
      format.text
      format.html
    end
  end

  def duplicate_purchases(email:, purchases:)
    @purchases = purchases
    @user_count = User.joins(:purchases).where(purchases: {id: purchases}).distinct.count
    @name = purchases.first.active_claim.detail.to_s
    membership_numbers = purchases.pluck(:membership_number).to_sentence
    mail(to: email, subject: "CoNZealand: Duplicate names for members #{membership_numbers}") do |format|
      #text must be called before html.
      format.text
      format.html
    end
  end
end
