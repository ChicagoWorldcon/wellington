# frozen_string_literal: true

# Copyright 2020 Victoria Garcia
# Copyright 2021 Fred Bauer - Worldcon 79/DisCon III 
#
# Licensed under the Apache License, Version 2.0 (the "License");

require "rails/all"
require "date"
require_relative "convention"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
module ConventionDetails
  class Worldcon79 < ConventionDetails::Convention

    attr_reader  :con_city, :con_city_previous, :con_country, :con_country_previous, :con_datews_informal_end, :con_dates_informal_start, :con_greeting_basic, :con_hugo_download_A4, :con_hugo_download_letter, :con_name_public, :con_name_public_previous, :con_number, :con_organizers_sigs, :con_url_homepage, :con_url_member_login, :con_url_privacy, :con_url_tos, :con_url_volunteering, :con_wsfs_constitution_link, :con_year, :contact_model, :registration_mailing_address, :site_theme, :translation_folder

    def initialize
      super
      @con_city = "Washington, DC"
      @con_city_previous = "Wellington"
      @con_country = "The USA"
      @con_country_previous = "New Zealand"
      @con_dates_informal_start = "Wednesday, August 25"
      @con_dates_informal_end = "Sunday, August 29th"
      @con_greeting_basic = "greetings"
      #FIXME: Update hugo ballot locations when we have them
      @con_hugo_download_A4 = "https://www.wsc.edu/download/downloads/id/1843/chicago_citation_style_examples_-_17th_edition.pdf"
      @con_hugo_download_letter = "https://www.wsc.edu/download/downloads/id/1843/chicago_citation_style_examples_-_17th_edition.pdf"
      @con_name_public = "DisCon III"
      @con_name_public_previous = "CoNZealand"
      @con_number = "worldcon79"
      @con_organizers_sigs = "Discon III Organizers"
      @con_url_homepage = "https://discon3.org/"
      @con_url_member_login = "https://members.discon3.org/"
      @con_url_privacy = "https://discon3.org/about/coc/"
      @con_url_tos = "https://discon3.org/about/coc/"
      @con_url_volunteering = "https://discon3.org/get-involved/volunteer/volunteering-opportunities/"
      @con_wsfs_constitution_link = "http://www.wsfs.org/wp-content/uploads/2020/08/WSFS-Constitution-as-of-August-1-2020.pdf"
      @con_year = "2021"
      @con_year_before = "2020"
      @contact_model = "dc"
      #FIXME: need mailing address
      @registration_mailing_address = <<~EOF
        DisCon III Member Services
        **Address needed**
        USA
        EOF
      @site_theme = "dc"
      @translation_folder = "dc"
    end
  end
end
