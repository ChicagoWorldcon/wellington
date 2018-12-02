# frozen_string_literal: true

class StripeKey < ActiveRecord::Base # rubocop:disable GitHub/RailsApplicationRecord
  self.primary_key = "key"
  self.inheritance_column = "not_a_column"
end
