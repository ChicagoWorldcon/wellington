class CreateReportRecipients < ActiveRecord::Migration[6.0]
  def change
    create_table :report_recipients do |t|
      t.string :report
      t.string :email_address

      t.timestamps
    end
  end
end
