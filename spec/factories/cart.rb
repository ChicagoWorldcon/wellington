FactoryBot.define do

  factory :cart do
    association :user
    status {"for_now"}
    active_from { 1.week.ago }

    trait :for_now_bin do
      status {"for_now"}
    end

    trait :for_later_bin do
      status {"for_later"}
    end

    trait :awaiting_cheque do
      status {"awaiting_cheque"}
    end

    trait :paid do
      status {"paid"}
    end

    trait :inactive do
      active_to { 1.day.ago }
    end

    trait :with_basic_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, cart: new_cart)
      end
    end

    trait :with_free_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :with_free_membership, cart: new_cart)
      end
    end

    trait :with_unavailable_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :unavailable, cart: new_cart)
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
        create_list(:cart_item, 3, :with_expired_membership, cart: new_cart)
      end
    end

    trait :with_partially_paid_reservation_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :with_partially_paid_reservation, cart: new_cart)
      end
    end

    trait :with_paid_reservation_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :with_paid_reservation, cart: new_cart)
      end
    end

    trait :with_unpaid_reservation_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :with_paid_reservation, cart: new_cart)
      end
    end

    trait :with_all_problematic_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 1, :name_altered, cart: new_cart)
        create_list(:cart_item, 1, :price_altered, cart: new_cart)
        create_list(:cart_item, 2, :unknown_kind, cart: new_cart)
        create_list(:cart_item, 2, :nonmembership_without_benefitable, cart: new_cart)
        create_list(:cart_item, 2, :with_expired_membership, cart: new_cart)
        create_list(:cart_item, 2, :with_paid_reservation, cart: new_cart)
      end
    end

    trait :with_10_mixed_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 2, cart: new_cart)
        create_list(:cart_item, 2, :unavailable, cart: new_cart)
        create_list(:cart_item, 2, :with_expired_membership, cart: new_cart)
        create_list(:cart_item, 2, :with_free_membership, cart: new_cart)
        create_list(:cart_item, 2, :with_unpaid_reservation, cart: new_cart)
      end
    end

    trait :with_100_mixed_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 30, cart: new_cart)
        create_list(:cart_item, 20, :unavailable, cart: new_cart)
        create_list(:cart_item, 25, :with_expired_membership, cart: new_cart)
        create_list(:cart_item, 20, :with_free_membership, cart: new_cart)
        create_list(:cart_item, 5, :with_unpaid_reservation, cart: new_cart)
      end
    end
  end
end
