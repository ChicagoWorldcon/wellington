class BuildPersonRow
  ExportError = Class.new(StandardError)

  HEADINGS = [
    "Full name",
    "PreferredFirstname",
    "PreferedLastname",
    "BadgeTitle",
    "BadgeSubtitle",
    "Address Line1",
    "Address Line2",
    "Country",
    "Email Address",
    "Notes",
    "Membership Status",
    "Stripe Payment ID",
    "Charge Amount",
    "Payment Comment",
    "Member Number"
  ].freeze

  attr_reader :person

  def initialize(person)
    @person = person
  end

  def to_row
    raise(ExportError, "Person##{person.id} has multiple successful payments") if person.payments.succeeded.count > 1
    raise(ExportError, "Person##{person.id} is missing a payment") if payment.nil?
    raise(ExportError, "Person##{person.id} payment does not match membership") unless person.membership === payment.type
    raise(ExportError, "Person##{person.id} payment is not in NZD") unless payment.currency == "nzd"

    [
      person.legal_name, # "Full name",
      person.public_first_name, # "PreferredFirstname",
      person.public_last_name, # "PreferedLastname",
      person.badge_name, # "BadgeTitle",
      person.badge_subtitle, # "BadgeSubtitle",
      person.city, # "Address Line1",
      person.state, # "Address Line2",
      person.country, # "Country",
      person.email, # "Email Address",
      "Imported from kansa. People##{person.id}", # "Notes",
      person.membership, # "Membership Status",
      payment.stripe_charge_id, # "Stripe Payment ID",
      payment.amount, # "Charge Amount"
      payment_comment, # "Payment Comment"
      person.member_number # "Member Number"
    ]
  end

  def payment
    @payment ||= person.payments.succeeded.first
  end

  def payment_comment
    "kansa payment##{payment.id} for #{payment.amount.to_f / 100}#{payment.currency.upcase} paid with token #{payment.stripe_token} for #{payment.type} (#{payment.category})"
  end
end
