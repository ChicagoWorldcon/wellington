FactoryBot.define do
  factory :download_counter do
    association :user

    count { 1 }
  end
end
