class PaymentCategory < ActiveRecord::Base
  self.table_name = "payment_categories"
  self.primary_key = "key"
end
