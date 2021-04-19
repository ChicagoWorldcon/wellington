FactoryBot.define do

  factory :cart do
    association :user
    status {"for_now"}
    active_from { 1.week.ago }

    trait :inactive do
      active_to { 1.day.ago }
    end

    trait :for_later_bin do
      status {"for_later"}
    end

    trait :paid do
      # NOTE:  All this trait does is set the status attribute.
      # If you want to mess around with subtotals and such, you
      # need to add some paid cart items,
      status {"paid"}
    end

    trait :awaiting_cheque do
      status {"awaiting_cheque"}
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

    trait :with_altered_price_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :price_altered, cart: new_cart)
      end
    end

     trait :with_altered_name_items do
       after(:create) do |new_cart, _evaluator|
         create_list(:cart_item, 3, :name_altered, cart: new_cart)
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
  end
end
