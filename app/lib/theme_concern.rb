# frozen_string_literal: true

# Copyright 2010 Chris Rose
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
  end

  # instance methods should also be created to reference the private ones aboe
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
end
