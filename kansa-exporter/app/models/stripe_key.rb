class StripeKey < ActiveRecord::Base
  self.primary_key = "key"
  self.inheritance_column = "not_a_column"
end
