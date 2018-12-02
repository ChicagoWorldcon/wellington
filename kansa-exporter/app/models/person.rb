# frozen_string_literal: true

class Person < ApplicationRecord
  self.table_name = "people"

  has_many :payments
end
