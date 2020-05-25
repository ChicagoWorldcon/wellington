require "administrate/base_dashboard"

class ChargeDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    reservation: Field::BelongsTo,
    id: Field::Number,
    stripe_response: Field::String.with_options(searchable: false),
    comment: Field::String,
    state: Field::String,
    stripe_id: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    transfer: Field::String,
    amount_cents: Field::Number,
    amount_currency: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  user
  reservation
  id
  stripe_response
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  user
  reservation
  id
  stripe_response
  comment
  state
  stripe_id
  created_at
  updated_at
  transfer
  amount_cents
  amount_currency
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  user
  reservation
  stripe_response
  comment
  state
  stripe_id
  transfer
  amount_cents
  amount_currency
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how charges are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(charge)
  #   "Charge ##{charge.id}"
  # end
end
