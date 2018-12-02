class Payment < ActiveRecord::Base
  self.table_name = "payments"
  self.inheritance_column = "not_a_column"

  belongs_to :person
  belongs_to :payment_category, foreign_key: "category"

  scope :succeeded, -> () { where(status: "succeeded") }
end
