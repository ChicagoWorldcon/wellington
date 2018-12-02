class Person < ActiveRecord::Base
  self.table_name = "people"

  has_many :payments
end
