# frozen_string_literal: true
#
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

# ChicagoContact represents a user's details as they enter them in their membership form
# User is associated to ChicagoContact through the Claim join table
# Membership is associated to ChicagoContact through the Reservation on Claim
# This very tightly coupled to app/views/reservations/_chicago_contact_form.html.erb
# ChicagoContact is created when a user creates a Reservation against a Membership

class EmailForPubsValidator < ActiveModel::Validator
  def validate(record)
    if /email/.match?(record.publication_format) && record.email.blank?
      record.errors.add(:publication_format, :email_requested_but_not_given, message: "can't specify email if an email address isn't provided")
      record.errors.add(:email, :email_needed_for_pubs, message: "can't be blank if publications are requested via email")
    end
  end
end
