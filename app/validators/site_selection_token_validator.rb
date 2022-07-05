# frozen_string_literal: true

#
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
class SiteSelectionTokenValidator < ActiveModel::Validator
  def validate(record)
    return unless record.site_selection_tokens.present?

    seen_elections = record.site_selection_tokens.pluck(:election)
    if seen_elections.uniq.size != seen_elections.size
      record.errors.add(:site_selection_tokens, :non_unique_election,
                        message: "can't have more than one token for an election")
    end
  end
end
