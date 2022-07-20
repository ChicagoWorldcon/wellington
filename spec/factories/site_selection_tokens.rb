FactoryBot.define do
  factory :site_selection_token do
    token { "Token" }
    voter_id { "Voter ID" }
    election { "worldcon" }  # this must match one of the elections defined in the i18 files... hacky af but it works

    trait :purchased do
      after(:create) do |new_token, _evaluator|
        create(:token_purchase, :with_token, site_selection_token: new_token)
      end
    end
  end
end
