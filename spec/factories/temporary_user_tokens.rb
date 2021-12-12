FactoryBot.define do
  factory :temporary_user_token do
    token { "temporary: generic" }
    active_from { 1.day.ago }
    active_to { 1.hour.from_now }

    factory :expired_token do
      token { "temporary: expired" }
      active_to { 1.minute.ago }
    end
  end
end
