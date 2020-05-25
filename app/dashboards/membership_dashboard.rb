require "administrate/base_dashboard"

class MembershipDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    orders: Field::HasMany,
    active_orders: Field::HasMany.with_options(class_name: "Order"),
    reservations: Field::HasMany,
    id: Field::Number,
    name: Field::String,
    active_from: Field::DateTime,
    active_to: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    description: Field::String,
    can_vote: Field::Boolean,
    can_attend: Field::Boolean,
    price_cents: Field::Number,
    price_currency: Field::String,
    can_nominate: Field::Boolean,
    can_site_select: Field::Boolean,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  orders
  active_orders
  reservations
  id
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  orders
  active_orders
  reservations
  id
  name
  active_from
  active_to
  created_at
  updated_at
  description
  can_vote
  can_attend
  price_cents
  price_currency
  can_nominate
  can_site_select
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  orders
  active_orders
  reservations
  name
  active_from
  active_to
  description
  can_vote
  can_attend
  price_cents
  price_currency
  can_nominate
  can_site_select
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

  # Overwrite this method to customize how memberships are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(membership)
  #   "Membership ##{membership.id}"
  # end
end
