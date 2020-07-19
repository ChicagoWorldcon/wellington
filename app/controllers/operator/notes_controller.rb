# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
# Copyright 2020 Steven Ensslen
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

# NotesController creates arbitary notes against users. Notes are supposed to be written but never modified.
class Operator::NotesController < ApplicationController
  before_action :authenticate_operator!
  before_action :lookup_user!

  def create
    @user.notes.create!(content: params[:content])
    redirect_to operator_user_path(@user)
  end
end
