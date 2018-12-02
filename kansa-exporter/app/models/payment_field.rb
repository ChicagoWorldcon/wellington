class PaymentField < ActiveRecord::Base
  self.table_name = "payment_fields"
  self.primary_key = "key"
  self.inheritance_column = "not_a_column"
end
