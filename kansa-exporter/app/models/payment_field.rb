# frozen_string_literal: true

class PaymentField < ActiveRecord::Base # rubocop:disable GitHub/RailsApplicationRecord
  self.table_name = "payment_fields"
  self.primary_key = "key"
  self.inheritance_column = "not_a_column"
end
