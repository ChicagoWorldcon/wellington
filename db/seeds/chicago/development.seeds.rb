# frozen_string_literal: true
#
# Copyright 2019 Chris Rose
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

if User.count > 0
  puts "Cowardly refusing to seed a database when we have existing users"
  exit 1
end

FactoryBot.create(:membership, :chicago_donor)
FactoryBot.create(:membership, :chicago_friend)
FactoryBot.create(:membership, :chicago_star)

# Create a default support user
# http://localhost:3000/supports/sign_in
Support.create(
  email: "support@worldcon.org",
  password: 111111,
  confirmed_at: Time.now,
)
