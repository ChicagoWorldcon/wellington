FactoryBot.define do

  factory :cart do
    association :user
    status {"for_now"}
    active_from { 1.week.ago }

    transient do
      num_charges {0}
      small_charges { false }
      small_charge_cents { 3_00 }
      adult_memb_charge_cents {370_00}
      charge_state { Charge::STATE_SUCCESSFUL }
      charge_transfer { Charge::TRANSFER_STRIPE }
    end

    after(:create) do |new_cart, eval|
      if eval.num_charges > 0
        cents_to_charge = (eval.small_charges ? eval.small_charge_cents : eval.adult_memb_charge_cents)

        create_list(:charge, eval.num_charges,
          state: eval.charge_state,
          transfer: eval.charge_transfer,
          user: new_cart.user,
          buyable: new_cart,
          amount_cents: cents_to_charge)
      end
    end

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
      # NOTE:  All this trait does is set the status attribute.
      # If you want to mess around with subtotals and such, you
      # need to add some paid cart items,
      status {"awaiting_cheque"}
    end

    trait :with_basic_items do
       after(:create) do |new_cart, _evaluator|
       create_list(:cart_item, 3, cart: new_cart)
      end
    end

    trait :with_supporting_membership_items do
      after(:create) do |new_cart, _evaluator|
        create_list(:cart_item, 3, :with_supporting_membership, cart: new_cart)
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
        create_list(:cart_item, 3, :with_unpaid_reservation, cart: new_cart)
      end
    end

    trait :fully_paid_through_single_direct_charge do
      transient do
        num_charges { 1 }
        adult_memb_charge_cents {370_00 * 3 }
      end

      after(:create) do |new_cart, evaluator|
        create_list(:cart_item, 3, :with_unpaid_reservation, cart: new_cart)
      end
    end

    trait :partially_paid_through_direct_charges do
      after(:create) do |new_cart, evaluator|
        create_list(:cart_item, 3, cart: new_cart)
      end

      transient do
        num_charges { 1 }
        small_charges { true }
      end
    end

    trait :fully_paid_through_direct_charge_and_paid_item_combo do
      after(:create) do |new_cart, evaluator|
        create_list(:cart_item, 2, :with_paid_reservation, cart: new_cart)
        create(:cart_item, :with_unpaid_reservation, cart: new_cart)
      end

      transient do
        num_charges { 1 }
      end
    end

    trait :partially_paid_through_direct_charge_and_paid_item_combo do
      after(:create) do |new_cart, evaluator|
        create_list(:cart_item, 4, :with_partially_paid_reservation, cart: new_cart)
      end

      transient do
        num_charges { 1 }
      end
    end

    trait :with_failed_charges do
      transient do
        num_charges { 3 }
        charge_state { Charge::STATE_FAILED }
      end
    end
  end
end
