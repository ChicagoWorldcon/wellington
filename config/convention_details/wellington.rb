
module ConventionDetails

    class Wellington < ConventionDetails::Convention

      attr_reader  :con_city, :con_city_previous, :con_country, :con_country_previous, :con_dates_informal_end, :con_dates_informal_start, :con_greeting_basic, :con_hugo_download_A4, :con_hugo_download_letter, :con_name_public, :con_name_public_previous, :con_organizers_sigs, :con_url_homepage, :con_url_member_login, :con_url_privacy, :con_url_tos, :con_url_volunteering, :con_wsfs_constitution_link, :con_year

      def initialize
        super
        @con_city_previous = "Dublin"
        @con_country = "New Zealand"
        @con_country_previous = "Ireland"
        @con_dates_informal_end = "Sunday, Aug 2nd"
        @con_dates_informal_start = "Wednesday, July 29th"
        @con_greeting_basic = "kia ora"
        @con_hugo_download_A4 = "https://conzealand.nz/wp-content/uploads/2019/12/2020-Hugo-Nominations-Ballot-Printable.pdf"
        @con_hugo_download_letter = "https://conzealand.nz/wp-content/uploads/2019/12/2020-Hugo-Nominations-Ballot-Printable-US-Letter.pdf"
        @con_name_public = "CoNZealand"
        @con_name_public_previous = "Dublin"
        @con_organizers_sigs = "Tammy Coxen, Nicholas Whyte and Ian Moore"
        @con_url_homepage = "https://conzealand.nz/"
        @con_url_member_login = "https://members.conzealand.nz"
        @con_url_privacy = "https://conzealand.nz/privacy-policy/"
        @con_url_tos = "https://conzealand.nz/about/explore-conzealand/policies-and-expectations/code-of-conduct"
        @con_url_volunteering = "https://conzealand.nz/conzealand-needs/volunteers"
        @con_wsfs_constitution_link = "=http://www.wsfs.org/wp-content/uploads/2019/11/WSFS-Constitution-as-of-August-19-2019.pdf"
        @con_year = "2020"

      end
    end
end
