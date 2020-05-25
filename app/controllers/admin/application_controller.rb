# All Administrate controllers inherit from this
# `Administrate::ApplicationController`, making it the ideal place to put
# authentication logic or other before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    before_action :authenticate_support!

    # Limit the scope of the given resource
    def scoped_resource
      super.where(user: current_support)
    end

    # Raise an exception if the user is not permitted to access this resource
    def authorize_resource(resource)
      raise "Unauthorized admin access" unless current_support.present?
      # raise "Erg!" unless show_action?(params[:action], resource)
    end

    # Hide links to actions if the user is not allowed to do them      
    def show_action?(action, resource)
      current_support.present?
      # current_user.can? action, resource
    end

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end
  end
end
