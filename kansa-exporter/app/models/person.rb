# frozen_string_literal: true

class Person < ActiveRecord::Base # rubocop:disable GitHub/RailsApplicationRecord
  self.table_name = "people"

  has_many :payments
end
