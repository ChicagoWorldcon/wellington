# frozen_string_literal: true

# Copyright 2020 Chris Rose
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

module ThemeConcern
  extend ActiveSupport::Concern

  class_methods do
    def theme_contact_param
      case Rails.configuration.contact_model
      when "chicago"
        :chicago_contact
      when "conzealand"
        :conzealand_contact
      when "dc"
        :dc_contact
      else
        raise "Unknown contact type: #{Rails.configuration.contact_model}"
      end
    end

    def theme_contact_class
      case Rails.configuration.contact_model
      when "chicago"
        ChicagoContact
      when "conzealand"
        ConzealandContact
      when "dc"
        DcContact
      else
        raise "Unknown contact type: #{Rails.configuration.contact_model}"
      end
    end

    def theme_contact_form
      case Rails.configuration.contact_model
      when "chicago"
        "chicago_contact_form"
      when "dc"
        "dc_contact_form"
      when "conzealand"
        "conzealand_contact_form"
      else
        raise "Unknown contact type: #{Rails.configuration.contact_model}"
      end
    end

    def theme_layout
      Rails.configuration.site_theme
    end

    def theme_con_public_name
      case Rails.configuration.con_public_name
      when "chicago"
        # TODO: Change to non-secret name before going live
        "Tasfic II"
      when "dc"
        "DisCon III"
      when "wellington"
        "CoNZealand"
      else
        raise "Unknown Convention Public Name: #{Rails.configuration.con_public_name}"
      end
    end

    def theme_con_start_day_informal
      case Rails.configuration.contact_model
      when "chicago"
        "Wednesday, August 31st"
      when "dc"
        "Wednesday, August 25"
      when "conzealand"
        "Wednesday, July 29th"
      else
        raise "Unknown contact type: #{Rails.configuration.contact_model}"
      end
    end

    def theme_con_end_day_informal
      case Rails.configuration.contact_model
      when "chicago"
        "Monday, September 5th"
      when "dc"
        "Sunday, August 29th"
      when "conzealand"
        "Sunday, Aug 2nd"
      else
        raise "Unknown contact type: #{Rails.configuration.contact_model}"
      end
    end

    def theme_previous_con_public_name
      case Rails.configuration.contact_model
      when "chicago"
        "Discon III"
      when "dc"
        "CoNZealand"
      when "conzealand"
        "Dublin"
      else
        raise "Unknown ConventionYear: #{Rails.configuration.con_year}"
      end
    end

    def theme_organizers_signing
      case Rails.configuration.contact_model
      when "chicago"
        "Helen Montgomery & co-conspirators"
      when "dc"
        "Discon III Organizers"
      when "conzealand"
        "Tammy Coxen, Nicholas Whyte and Ian Moore"
      else
        raise "Unknown contact type: #{Rails.configuration.contact_model}"
      end
    end

    def theme_hugo_ballot_download_link_a4
      case Rails.configuration.contact_model
      when "chicago"
        "https://www.wsc.edu/download/downloads/id/1843/chicago_citation_style_examples_-_17th_edition.pdf"
      when "dc"
        "https://www.si.edu/content/pdf/about/SmithsonianDigitalActionAgenda.pdf"
      when "conzealand"
        "https://conzealand.nz/wp-content/uploads/2019/12/2020-Hugo-Nominations-Ballot-Printable.pdf"
      else
        raise "Unknown contact type: #{Rails.configuration.contact_model}"
      end
    end

    def theme_hugo_ballot_download_link_letter
      case Rails.configuration.contact_model
      when "chicago"
        "https://www.wsc.edu/download/downloads/id/1843/chicago_citation_style_examples_-_17th_edition.pdf"
      when "dc"
        "https://www.si.edu/content/pdf/about/SmithsonianDigitalActionAgenda.pdf"
      when "conzealand"
        "https://conzealand.nz/wp-content/uploads/2019/12/2020-Hugo-Nominations-Ballot-Printable-US-Letter.pdf"
      else
        raise "Unknown contact type: #{Rails.configuration.contact_model}"
      end
    end

    def theme_con_member_login_url
      case Rails.configuration.contact_model
      when "chicago"
        "https://members.chicon.org/"
      when "dc"
        "https://members.discon3.org/"
      when "conzealand"
        "https://members.conzealand.nz"
      else
        raise "Unknown contact type: #{Rails.configuration.contact_model}"
      end
    end

    def theme_hugo_help_email
      Rails.configuration.hugo_help_email
    end

    def theme_con_year
      Rails.configuration.con_year
    end

    def theme_con_city
      Rails.configuration.con_city
    end

    def theme_con_city_previous
      Rails.configuration.con_city_previous
    end

    def theme_con_tos_url
      Rails.configuration.worldcon_tos_url
    end

    def theme_con_volunteering_url
      Rails.configuration.worldcon_volunteering_url
    end

    def theme_con_privacy_url
      Rails.configuration.worldcon_privacy_policy_url
    end

    def theme_con_homepage_url
      Rails.configuration.worldcon_homepage_url
    end

    def theme_con_country
      case Rails.configuration.con_country
      when "us"
        "the USA"
      when "dc"
        "the USA"
      when "new zealand"
        "New Zealand"
      else
        raise "Unknown Convention Country: #{Rails.configuration.con_country}"
      end
    end

    def theme_greeting
      case Rails.configuration.basic_greeting
      when "chicago"
        "hi there, friend"
      when "dc"
        "hello"
      when "wellington"
        "kia ora"
      else
        raise "Unknown Convention Public Name: #{Rails.configuration.basic_greeting}"
      end
    end

    def theme_wsfs_constitution_link
      Rails.configuration.wsfs_constitution_link
    end
  end

  # instance methods should also be created to reference the private ones above
  private

  def theme_contact_param
    self.class.theme_contact_param
  end

  def theme_contact_class
    self.class.theme_contact_class
  end

  def theme_contact_form
    self.class.theme_contact_form
  end

  def theme_con_public_name
    self.class.theme_con_public_name
  end

  def theme_con_year
    self.class.theme_con_year
  end

  def theme_con_city
    self.class.theme_con_city
  end

  def theme_con_country
    self.class.theme_con_country
  end

  def theme_con_tos_url
    self.class.theme_con_tos_url
  end

  def theme_con_privacy_url
    self.class.theme_con_privacy_url
  end

  def theme_con_homepage_url
    self.class.theme_con_homepage_url
  end

  def theme_con_city_previous
    self.class.theme_con_city_previous
  end

  def theme_previous_con_public_name
    self.theme_previous_con_public_name
  end

  def theme_organizers_signing
    self.theme_organizers_signing
  end

  def theme_wsfs_constitution_link
    self.theme_wsfs_constitution_link
  end

  def theme_con_member_login_url
    self.theme_con_member_login_url
  end
end
