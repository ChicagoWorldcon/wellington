FactoryBot.define do
  factory :site_selection_token do
    token { "MyString" }
    voter_id { "MyString" }
    election { "MyString" }
  end
end
