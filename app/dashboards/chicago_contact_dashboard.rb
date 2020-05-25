require "administrate/base_dashboard"

class ChicagoContactDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    claim: Field::BelongsTo,
    id: Field::Number,
    import_key: Field::String,
    title: Field::String,
    first_name: Field::String,
    last_name: Field::String,
    preferred_first_name: Field::String,
    preferred_last_name: Field::String,
    badge_subtitle: Field::String,
    badge_title: Field::String,
    address_line_1: Field::String,
    address_line_2: Field::String,
    city: Field::String,
    country: Field::String,
    postal: Field::String,
    province: Field::String,
    publication_format: Field::String,
    interest_accessibility_services: Field::Boolean,
    interest_being_on_program: Field::Boolean,
    interest_dealers: Field::Boolean,
    interest_exhibiting: Field::Boolean,
    interest_performing: Field::Boolean,
    interest_selling_at_art_show: Field::Boolean,
    interest_volunteering: Field::Boolean,
    share_with_future_worldcons: Field::Boolean,
    show_in_listings: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  claim
  id
  import_key
  title
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  claim
  id
  import_key
  title
  first_name
  last_name
  preferred_first_name
  preferred_last_name
  badge_subtitle
  badge_title
  address_line_1
  address_line_2
  city
  country
  postal
  province
  publication_format
  interest_accessibility_services
  interest_being_on_program
  interest_dealers
  interest_exhibiting
  interest_performing
  interest_selling_at_art_show
  interest_volunteering
  share_with_future_worldcons
  show_in_listings
  created_at
  updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  claim
  import_key
  title
  first_name
  last_name
  preferred_first_name
  preferred_last_name
  badge_subtitle
  badge_title
  address_line_1
  address_line_2
  city
  country
  postal
  province
  publication_format
  interest_accessibility_services
  interest_being_on_program
  interest_dealers
  interest_exhibiting
  interest_performing
  interest_selling_at_art_show
  interest_volunteering
  share_with_future_worldcons
  show_in_listings
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

  # Overwrite this method to customize how chicago contacts are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(chicago_contact)
  #   "ChicagoContact ##{chicago_contact.id}"
  # end
end
