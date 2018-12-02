require "csv"

class ExportPeople
  def call
    CSV.generate do |csv|
      csv << BuildPersonRow::HEADINGS

      Person.order(:id).find_each do |person|
        builder = BuildPersonRow.new(person)
        csv << builder.to_row
      end
    end
  end
end
