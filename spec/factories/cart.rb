FactoryBot.define do
  factory :cart do
    association :user
    status {"pending"}
    active_from { 1.week.ago }

    trait :with_basic_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, cart: new_cart)
      end
    end

    trait :with_free_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :with_kidit, cart: new_cart)
      end
    end

    trait :with_items_for_later do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :saved_for_later, cart: new_cart)
      end
    end

    trait :with_unavailable_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :unavailable, cart: new_cart)
      end
    end

    trait :with_incomplete_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :incomplete, cart: new_cart)
      end
    end

    trait :with_altered_name_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :name_altered, cart: new_cart)
      end
    end

    trait :with_altered_price_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :price_altered, cart: new_cart)
      end
    end

    trait :with_unknown_kind_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :unknown_kind, cart: new_cart)
      end
    end

    trait :with_expired_membership_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :with_expired_membership_tuatara, cart: new_cart)
      end
    end

    trait :with_all_problematic_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 2, :price_altered, cart: new_cart)
        create_list(:cart_item, 2, :name_altered, cart: new_cart)
        create_list(:cart_item, 2, :unknown_kind, cart: new_cart)
        create_list(:cart_item, 2, :nonmembership_without_benefitable, cart: new_cart)
        create_list(:cart_item, 2, :with_expired_membership_silver_f, cart: new_cart)
      end
    end

    trait :with_10_mixed_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 2, cart: new_cart)
        create_list(:cart_item, 2, :unavailable, cart: new_cart)
        create_list(:cart_item, 2, :with_expired_membership_silver_f, cart: new_cart)
        create_list(:cart_item, 2, :saved_for_later, cart: new_cart)
        create_list(:cart_item, 1, :with_kidit, cart: new_cart)
        create_list(:cart_item, 1, :incomplete, cart: new_cart)
      end
    end

    trait :with_100_mixed_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 25, cart: new_cart)
        create_list(:cart_item, 15, :unavailable, cart: new_cart)
        create_list(:cart_item, 15, :with_expired_membership_silver_f, cart: new_cart)
        create_list(:cart_item, 15, :incomplete, cart: new_cart)
        create_list(:cart_item, 15, :saved_for_later, cart: new_cart)
        create_list(:cart_item, 15, :with_kidit, cart: new_cart)
      end
    end

    trait :with_unknown_kind_saved_for_later_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :unknown_kind_saved_for_later, cart: new_cart)
      end
    end

    trait :with_unavailable_saved_for_later_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :unavailable_saved_for_later, cart: new_cart)
      end
    end

    trait :with_incomplete_saved_for_later_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :incomplete_saved_for_later, cart: new_cart)
      end
    end

    trait :with_price_altered_saved_for_later_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :price_altered_saved_for_later, cart: new_cart)
      end
    end

    trait :with_name_altered_saved_for_later_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :name_altered_saved_for_later, cart: new_cart)
      end
    end

    trait :with_expired_saved_for_later_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :expired_saved_for_later, cart: new_cart)
      end
    end
  end
end
