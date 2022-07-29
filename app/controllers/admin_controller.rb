class AdminController < ApplicationController
  before_action :ensure_support_signed_in!

  def index
    @reports = [["Membership", :membership], ["Ranks", :ranks]]
  end

  def act
    case params[:report_name]
    when "membership"
      ReportMailer.memberships_csv.deliver_later
      flash[:notice] = "Sent the membership report to the configured recipients"
      redirect_to({ action: "index" })
    when "ranks"
      ReportMailer.ranks_csv.deliver_later
      flash[:notice] = "Sent the rank report to the configured recipients"
      redirect_to({ action: "index" })
    else
      head :not_found
    end
  end

  private

  def ensure_support_signed_in!
    head :forbidden unless support_signed_in?
  end
end
