# frozen_string_literal: true

# Copyright 2021 Fred Bauer
#
# Licensed under the Apache License, Version 2.0 (the "License");

# ThemesController allows users to browse and work on Themes for their con without
# needing to browse around the entire con website. From here you get a feel for how things will render
class SiteTokensController < ApplicationController
  LAYOUTS = "app/views/layouts"

  layout -> { params[:id] }, only: :show

  def index
    layouts = Dir.each_child("#{Rails.root}/#{LAYOUTS}").to_a
    html_layouts = layouts.select { |file| file.match(/html/) }
    @themes = html_layouts.map { |file| file.gsub(/\.html.*/, "") }
  end

  def get(member)
    token = member.to_s
  end
end
