# frozen_string_literal: true

class PaymentCategory < ApplicationRecord
  self.table_name = "payment_categories"
  self.primary_key = "key"
end
