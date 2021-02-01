FactoryBot.define do
  factory :cart_item do
    kind {"membership"}
    later {false}
    available {true}
    created_at { 1.week.ago }

    after(:build) do |new_cart_item, evaluator|
      new_cart_item.chicago_contact = create(:chicago_contact, cart_item: new_cart_item)
    end



    trait :with_expired_membership do
    end

    trait :with_active_membership do
    end

    trait :saved_for_later do
    end

    trait :costs_nothing do
    end

    trait :unavailable do
    end

  end
end
