require 'delegate'

module Wellington

  def self.details
    worldcon_number = (
      ENV["WORLDCON_NUMBER"] || abort("While there are optional configurations, WORLDCON_NUMBER isn't one. Set this.")
    ).strip

    # Load our con-specific configuration bundle
    require_relative "convention_details/convention"
    require_relative "convention_details/#{worldcon_number}"
    convention_details_class = ConventionDetails.const_get(worldcon_number.capitalize)
    DetailsDelegate.new convention_details_class.new
  end

  class DetailsDelegate < SimpleDelegator
  end
end
