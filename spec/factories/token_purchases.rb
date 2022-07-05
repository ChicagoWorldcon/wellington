FactoryBot.define do
  factory :token_purchase do
    site_selection_token { nil }
    reservation { create(:reservation) }

    trait :with_token do
      after(:create) do |new_token, evaluator|
        new_token.update!(site_selection_token: evaluator.site_selection_token)
      end
    end
  end
end
