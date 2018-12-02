# frozen_string_literal: true

class PaymentType < ApplicationRecord
  self.table_name = "payment_types"
  self.primary_key = "key"

  belongs_to :payment_category, foreign_key: "category"
end
