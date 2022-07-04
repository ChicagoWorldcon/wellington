FactoryBot.define do
  factory :token_purchase do
    site_selection_token { nil }
    reservation { nil }
  end
end
