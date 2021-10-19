FactoryBot.define do
  factory :site_token do
    membership_number { 1 }
    token { "MyString" }
  end
end
