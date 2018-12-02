FactoryBot.define do
  factory :payment do
    sequence(:id) { |n| n }
    sequence(:stripe_charge_id) { |n| "ch_#{n.to_s.rjust(15, "0")}" }
    sequence(:stripe_token) { |n| "tok_#{n.to_s.rjust(15, "0")}" }
    status { "succeeded" }
    amount { 19500 }
    currency { "nzd" }
    type { "Adult" }
    category {  "new_member" }
  end
end
