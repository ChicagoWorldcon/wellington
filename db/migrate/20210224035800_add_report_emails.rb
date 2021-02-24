class AddReportEmails < ActiveRecord::Migration[6.0]
  def up
    ReportRecipient.create(report: "nomination", email_address: $nomination_reports_email)
    ReportRecipient.create(report: "membership", email_address: $membership_reports_email)
  end

  def down
    ReportRecipient.delete_all
  end
end
