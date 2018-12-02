# frozen_string_literal: true

class StripeKey < ApplicationRecord
  self.primary_key = "key"
  self.inheritance_column = "not_a_column"
end
