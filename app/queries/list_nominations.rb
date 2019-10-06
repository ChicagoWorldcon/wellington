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

# ListNominations given a reservation will give you objects to list out nominations for a user
class ListNominations
  attr_reader :reservation

  def initialize(reservation)
    @reservation = reservation
  end

  def call
    check_reservation
    nil
  end

  def errors
    @errors ||= []
  end

  private

  def check_reservation
    if reservation.instalment?
      errors << "membership isn't paid for yet"
    end
  end
end
