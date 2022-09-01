class AdminController < ApplicationController
  before_action :ensure_support_signed_in!

  REPORTS = [
    { name: "Membership", id: :membership, method: :memberships_csv },
    { name: "Ranks", id: :ranks, method: :ranks_csv },
    { name: "Site Selection", id: :siteselection, method: :site_selection_csv },
    { name: "Virtual", id: :virtual, method: :virtual_memberships_csv }
  ]

  def index
    @reports = REPORTS.map { |r| [r[:name], r[:id]] }
  end

  def act
    report = REPORTS.detect { |e| e[:id] == params[:report_name].to_sym }
    if report.nil?
      head :not_found
      return
    end

    ReportMailer.send(report[:method]).deliver_later
    flash[:notice] = "Sent the #{report[:name]} report to the configured recipients"
    redirect_to({ action: "index" })
  end

  private

  def ensure_support_signed_in!
    head :forbidden unless support_signed_in?
  end
end
