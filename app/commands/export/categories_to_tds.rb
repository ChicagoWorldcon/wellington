# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
# Copyright 2021 Fred Bauer
#15-Feb 21 FNB remove retro. Other fixes for TDS

# Export::CategoriesToTds puts categories stored in our system and syncs them with Dave's SQL Server setup
# This SQL Server backs admin for the Hugo Nominations
class Export::CategoriesToTds
  include ::Export::TdsClient
  include ActionView::Helpers::TextHelper

  MAX_CATEGORY_LENTH = 30

  def initialize(verbose: false)
    @verbose = verbose
  end

  def call
    execute("DELETE FROM Award_Categories_2020").do
    result = execute(
      %{
        INSERT INTO Award_Categories_2020
          ( BallotPosition, CategoryID, CategoryName )
        VALUES
          #{categories_2020.size.times.map { "( %i, %i, '%s')" }.join(",")}
        ;
      },
      categories_2020.flat_map do |category|
        [category.order || 0, category.id, cludge(category.name)]
      end
    )
    result.insert # Hack to acknowledge we've read the result from SQL Server
    result.do

    # execute("DELETE FROM Award_Categories_1945")
    # result = execute(
    #   %{
    #     INSERT INTO Award_Categories_1945
    #       ( BallotPosition, CategoryID, CategoryName )
    #     VALUES
    #       #{categories_1945.size.times.map { "( %i, %i, '%s')" }.join(",")}
    #     ;
    #   },
    #   categories_1945.flat_map do |category|
    #     [category.order || 0, category.id, cludge(category.name)]
    #   end
    # )
    # result.insert # Hack to acknowledge we've read the result from SQL Server
  end

  private

  # Turns out we've got arbitry limits on this field
  # So we have to strip or replace words that don't help our admins
  def cludge(name)
    name = name.gsub(/ for .*/i, "")
    name = name.gsub(/retro/i, "")
    name = name.gsub(/best/i, "")
    name = name.gsub("Dramatic Presentation", "D-Presentation")
    truncate(name.strip, length: MAX_CATEGORY_LENTH)
  end

  def categories_1945
    Category.joins(:election).where(elections: {i18n_key: "retro_hugo"})
  end

  def categories_2020
    Category.joins(:election).where(elections: {i18n_key: "hugo"})
  end
end
