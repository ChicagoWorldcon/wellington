# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
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

class TestMailer < ApplicationMailer
  include ApplicationHelper
  def this_is_just_a_test(subject:, to:, from: $member_services_email)
    @init_cap_greeting = worldcon_greeting_init_caps
    @test_subject = subject
    mail(subject: "Testing #{subject}", to: to, from: from)
  end
end
