# frozen_string_literal: true

class PaymentCategory < ActiveRecord::Base # rubocop:disable GitHub/RailsApplicationRecord
  self.table_name = "payment_categories"
  self.primary_key = "key"
end
