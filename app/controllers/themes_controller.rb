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

# ThemesController allows users to browse and work on Themes for their con without
# needing to browse around the entire con website. From here you get a feel for how things will render
class ThemesController < ApplicationController
  LAYOUTS = "app/views/layouts"

  layout -> { params[:id] }, only: :show

  def index
    layouts = Dir.each_child("#{Rails.root}/#{LAYOUTS}").to_a
    html_layouts = layouts.select { |file| file.match(/html/) }
    @themes = html_layouts.map { |file| file.gsub(/\.html.*/, "") }
  end

  def show
  end
end
