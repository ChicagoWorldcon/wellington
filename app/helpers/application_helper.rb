# frozen_string_literal: true

# Copyright 2019 AJ Esler
# Copyright 2020 Matthew B. Gray
# Copyright 2020 Victoria Garcia
# Copyright 2020 Steven Ensslen
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

module ApplicationHelper

  include ThemeConcern

  DEFUALT_NAV_CLASSES = %w(navbar navbar-dark shadow-sm).freeze

  # The root page has an expanded menu
  def navigation_classes
    if request.path == root_path
      DEFUALT_NAV_CLASSES
    else
      DEFUALT_NAV_CLASSES + %w(bg-dark)
    end.join(" ")
  end

  # These match i18n values set in config/locales
  # see Membership#all_rights
  def membership_right_description(membership_right, reservation)
    description = I18n.t(:description, scope: membership_right)
    if membership_right == "rights.attend" && ENV["VIRTUAL_WORLDCON_URL"].present?
      link_to description, ENV["VIRTUAL_WORLDCON_URL"]
    elsif membership_right == "rights.site_selection" && ENV["SITE_SELECTION_URL"].present?
      link_to description, ENV["SITE_SELECTION_URL"]
    elsif match = membership_right.match(/rights\.(.*)\.nominate\z/)
      election_i18n_key = match[1]
      link_to description, reservation_nomination_path(reservation_id: reservation, id: election_i18n_key)
    elsif match = membership_right.match(/rights\.(.*)\.nominate_only\z/)
      election_i18n_key = match[1]
      link_to description, reservation_nomination_path(reservation_id: reservation, id: election_i18n_key)
    elsif finalists_loaded? && match = membership_right.match(/rights\.(.*)\.vote\z/)
      election_i18n_key = match[1]
      link_to description, reservation_finalist_path(reservation_id: reservation, id: election_i18n_key)
    else
      description
    end
  end

  def fuzzy_time(as_at, unset_text: "open ended")
    content_tag(
      :span,
      as_at ? fuzzy_time_in_words(as_at) : unset_text,
      title: as_at&.iso8601 || "Time not set",
    )
  end

  def fuzzy_time_in_words(as_at)
    if as_at.nil?
      "open ended"
    elsif as_at < Time.now
      "#{time_ago_in_words(as_at)} ago"
    else
      "#{time_ago_in_words(as_at)} from now"
    end
  end

  def pretty_print(hash)
    formattable = [
      '<code>',
      JSON.pretty_generate(hash),
      '</code>',
    ].join("\n")
  end

  def markdown
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
  end

  def finalists_loaded?
    @voting_open ||= Finalist.count > 0
  end

  def worldcon_contact_form
    ApplicationHelper.theme_contact_form
  end


  #### Con City Helpers
  def worldcon_city
    Rails.configuration.convention_details.con_city
  end

  def worldcon_previous_city
    Rails.configuration.convention_details.con_city_previous
  end

  #### Con Country Helpers
  def worldcon_country
    Rails.configuration.convention_details.con_country
  end

  def worldcon_country_previous
    Rails.configuration.convention_details.con_country_previous
  end

  #### Con Start and End Date Helpers
  def start_day_informal
    Rails.configuration.convention_details.con_dates_informal_start
  end

  def end_day_informal
    Rails.configuration.convention_details.con_dates_informal_end
  end

  #### Con Greeting Helpers
  def worldcon_basic_greeting
    Rails.configuration.convention_details.con_greeting_basic
  end

  def worldcon_greeting_init_caps
    self.worldcon_basic_greeting.split.map{|word| word.capitalize}.inject { |accum, w| accum.concat(" ").concat(w) }.strip
  end

  def worldcon_greeting_sentence
    self.worldcon_basic_greeting.capitalize.concat(".")
  end

  def worldcon_greeting_sentence_excited
    self.worldcon_basic_greeting.capitalize.concat("!")
  end

  #### Hugo Info Helpers
  def hugo_ballot_download_a4
    Rails.configuration.convention_details.con_hugo_download_A4
  end

  def hugo_ballot_download_letter
    Rails.configuration.convention_details.con_hugo_download_letter
  end

  def hugo_nom_start
    $nomination_opens_at.strftime("%A %-d %B %Y, %H:%M %p %Z")
  end

  def hugo_nom_deadline
    $voting_opens_at.strftime("%A %-d %B %Y, %H:%M %p %Z")
  end

  def hugo_vote_deadline
    $hugo_closed_at.strftime("%A %-d %B %Y, %H:%M %p %Z")
  end

  # FIXME: When we add the new global variable for start of Hugo voting, this should be replaced with a method that reports that date's month.
  def hugo_ballot_pub_month
    rough_guess_month = Date._parse($hugo_closed_at.to_s)[:mon] + 1
    rough_guess_year = Date._parse($hugo_closed_at.to_s)[:year]
    if (rough_guess_month > 12)
      rough_guess_month = rough_guess_month - 12
      rough_guess_year = rough_guess_year + 1
    end
    return "#{Date::MONTHNAMES[rough_guess_month]} #{rough_guess_year}"
  end

  #### Public Name Helpers
  def worldcon_public_name
    Rails.configuration.convention_details.con_name_public
  end

  def worldcon_public_name_spaceless
    self.worldcon_public_name.remove(" ");
  end

  def previous_worldcon_public_name
    Rails.configuration.convention_details.con_name_public_previous
  end

  def worldcon_number
    # for example, 'worldcon80'
    Rails.configuration.convention_details.con_number
  end

  def worldcon_number_digits_only
    worldcon_number.gsub(/worldcon/i, '').to_i
  end

  #### Organizer Signature Helpers
  def organizers_names_for_signature
    Rails.configuration.convention_details.con_organizers_sigs
  end

  #### External URL Helpers
  def worldcon_url_homepage
    Rails.configuration.convention_details.con_url_homepage
  end

  def member_login_url
    Rails.configuration.convention_details.con_url_member_login
  end

  def worldcon_url_tos
    Rails.configuration.convention_details.con_url_tos
  end

  def worldcon_url_privacy
    Rails.configuration.convention_details.con_url_privacy
  end

  def worldcon_url_volunteering
    Rails.configuration.convention_details.con_url_volunteering
  end

  def worldcon_registration_mailing_address
    Rails.configuration.convention_details.registration_mailing_address
  end

  def wsfs_constitution_link
    Rails.configuration.convention_details.con_wsfs_constitution_link
  end

  #### Convention Year Helpers
  def worldcon_year
    Rails.configuration.convention_details.con_year
  end

  def worldcon_year_before
   ((self.worldcon_year.to_i) - 1).to_s
  end

  def worldcon_year_after
   ((self.worldcon_year.to_i) + 1).to_s
  end

  def retro_hugo_75_ago
   ((self.worldcon_year.to_i) - 75).to_s
  end

  def retro_hugo_50_ago
   ((self.worldcon_year.to_i) - 50).to_s
  end

  def retro_hugo_25_ago
   ((self.worldcon_year.to_i) - 25).to_s
  end

  def site_selection_year
   ((self.worldcon_year.to_i) + 2).to_s
  end

  #### Email Helpers
  def email_hugo_help
    $hugo_help_email
  end

  def mailto_hugo_help
    "mailto:" + self.email_hugo_help
  end
end
