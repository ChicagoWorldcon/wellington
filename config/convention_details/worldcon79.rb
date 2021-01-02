module ConventionDetails

  class Dc < ConventionDetails::Convention

    attr_reader  :con_city, :con_city_previous, :con_country, :con_country_previous, :con_dates_informal_end, :con_dates_informal_start, :con_greeting_basic, :con_hugo_download_A4, :con_hugo_download_letter, :con_name_public, :con_name_public_previous, :con_number, :con_organizers_sigs, :con_url_homepage, :con_url_member_login, :con_url_privacy, :con_url_tos, :con_url_volunteering, :con_wsfs_constitution_link, :con_year, :contact_model, :site_theme, :translation_folder

    def initialize
      super
      @con_city = "Washington, DC"
      @con_city_previous = "Wellington"
      @con_country = "The USA"
      @con_country_previous = "New Zealand"
      @con_dates_informal_end = "Sunday, August 29th"
      @con_dates_informal_start = "Wednesday, August 25"
      @con_greeting_basic = "greetings"
      @con_hugo_download_A4 = "https://www.si.edu/content/pdf/about/SmithsonianDigitalActionAgenda.pdf"
      @con_hugo_download_letter = "https://www.si.edu/content/pdf/about/SmithsonianDigitalActionAgenda.pdf"
      @con_name_public = "Discon III"
      @con_name_public_previous = "CoNZealand"
      @con_number = "worldcon79"
      @con_organizers_sigs = "Discon III Organizers"
      @con_url_homepage = "https://discon3.org/"
      @con_url_member_login = "https://members.discon3.org/"
      @con_url_privacy = "https://discon3.org/about/coc/"
      @con_url_tos = "https://discon3.org/about/coc/"
      @con_url_volunteering = "https://discon3.org/get-involved/volunteer/volunteering-opportunities/"
      @con_wsfs_constitution_link = "=http://www.wsfs.org/wp-content/uploads/2019/11/WSFS-Constitution-as-of-August-19-2019.pdf"
      @con_year = "2021"
      @contact_model = "dc"
      @site_theme = "dc"
      @translation_folder = "dc"
    end
  end
end
