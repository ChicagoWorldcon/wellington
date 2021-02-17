# frozen_string_literal: true
#
# Copyright 2021 Victoria Garcia
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

module DateOfBirthParamsHelper
  include ThemeConcern

  DATESELECT_KEY_1 = "dob_array(1i)"
  DATESELECT_KEY_2 = "dob_array(2i)"
  DATESELECT_KEY_3 = "dob_array(3i)"
  DATE_OF_BIRTH = "date_of_birth"

  def self.generate_dob_from_params(params)
    params_to_check = params.key?(theme_contact_param) ? params[theme_contact_param] : params
    if single_date_of_birth_param_present?(params_to_check)
      return Date.parse(params_to_check[DATE_OF_BIRTH])
    elsif dateselect_params_present?(params_to_check)
      return convert_dateselect_params_to_date(params_to_check)
    else
      return nil
    end
  end

  def self.single_date_of_birth_param_present?(params)
    return params.key?(DATE_OF_BIRTH)
  end

  def single_date_of_birth_param_present?(params)
    DateOfBirthParamsHelper.date_of_birth_present?(params)
  end

  def self.dateselect_params_present?(params)
    return params.key?(DATESELECT_KEY_1) && params.key?(DATESELECT_KEY_2) &&
    params.key?(DATESELECT_KEY_3)
  end

  def dateselect_params_present?(params)
    DateOfBirthParamsHelper.dob_params_present?(params)
  end

  def self.convert_dateselect_params_to_date_object(params)
    Date.new(
      params[DATESELECT_KEY_1].to_i,
      params[DATESELECT_KEY_2].to_i,
      params[DATESELECT_KEY_3].to_i,
    )
  end

  def convert_dateselect_params_to_date(params)
    DateOfBirthParamsHelper.convert_dateselect_params_to_date(params)
  end
end
