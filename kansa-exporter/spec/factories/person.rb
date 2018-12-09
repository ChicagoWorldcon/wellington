# frozen_string_literal: true

FactoryBot.define do
  factory :person do
    sequence(:id) { |n| n }
    legal_name { "Bartholemew J Fitzgerald" }
    public_first_name { "Bartholemew" }
    public_last_name { "Fitzgerald" }
    badge_name { "Super Fancy" }
    badge_subtitle { "with a monocle" }
    city { "123 Test St" }
    state { "Miramar" }
    country { "New Zealand" }
    email { "bart.f@example.com" }
    membership { "Adult" }
    sequence(:member_number) { |n| n }
  end
end
