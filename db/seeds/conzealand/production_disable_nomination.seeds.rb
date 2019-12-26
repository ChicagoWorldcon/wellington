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

nomination_rights_end_at = "2019-12-31T23:59:59 PST".to_datetime
Membership.can_nominate.where(active_to: nil).find_each do |current_membership|
  current_membership.transaction do
    membership_without_rights = current_membership.dup
    membership_without_rights.update!(
      active_from: nomination_rights_end_at,
      can_nominate: false,
    )
    current_membership.update!(active_to: nomination_rights_end_at)
    puts "#{current_membership.name} membership nomination rights end at #{nomination_rights_end_at}"
  end
end
