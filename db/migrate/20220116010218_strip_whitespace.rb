class StripWhitespace < ActiveRecord::Migration[6.1]
  def change
    update <<~SQL
    UPDATE chicago_contacts SET title=TRIM(title),
      first_name=TRIM(first_name),
      last_name=TRIM(last_name),
      preferred_first_name=TRIM(preferred_first_name),
      preferred_last_name=TRIM(preferred_last_name),
      badge_subtitle=TRIM(badge_subtitle),
      badge_title=TRIM(badge_title),
      address_line_1=TRIM(address_line_1),
      address_line_2=TRIM(address_line_2),
      city=TRIM(city),
      country=TRIM(country),
      postal=TRIM(postal),
      province=TRIM(province),
      publication_format=TRIM(publication_format)
    SQL
  end
end
