# frozen_string_literal: true

class Daypass < ActiveRecord::Base # rubocop:disable GitHub/RailsApplicationRecord
  belongs_to :person
end
