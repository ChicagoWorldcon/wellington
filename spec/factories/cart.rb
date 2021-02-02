FactoryBot.define do
  factory :cart do
    association :user
    status {"pending"}

    # VEG NOTE: It really doesn't seem
    # like we should have to shovel
    # this stuff into cart_items this way,
    # but that's what happens elsewhere in
    # our factory code.  Watch for inadvertent
    # doubles/weird behavior here.
    trait :with_basic_items do
      after(:create) do |new_cart, _evaluator|
        aa_item = create(:cart_item, cart: new_cart)
        new_cart.cart_items << aa_item

        ya_item = create(:cart_item, :with_ya, cart: new_cart)
        new_cart.cart_items << ya_item

        su_item = create(:cart_item, :with_supporting, cart: new_cart)
        new_cart.cart_items << su_item
      end
    end

    trait :with_free_items do
      after(:create) do |new_cart, _evaluator|
        ki_item1 = create(:cart_item, :with_kidit, cart: new_cart)
        new_cart.cart_items << ki_item1

        ki_item2 = create(:cart_item, :with_kidit, cart: new_cart)
        new_cart.cart_items << ki_item2

        ki_item3 = create(:cart_item, :with_kidit, cart: new_cart)
        new_cart.cart_items << ki_item3
      end
    end

    trait :with_items_for_later do
      after(:create) do |new_cart, _evaluator|
        aa_item = create(:cart_item, cart: new_cart, later: true)
        new_cart.cart_items << aa_item

        ki_item = create(:cart_item, :with_kidit, cart: new_cart, later: true)
        new_cart.cart_items << ki_item
      end
    end

    trait :with_unavailable_items do
      after(:create) do |new_cart, _evaluator|
        aa_item = create(:cart_item, :unavailable, cart: new_cart)
        new_cart.cart_items << aa_item
        ya_item = create(:cart_item, :with_ya, :unavailable, cart: new_cart)
        new_cart.cart_items << ya_item
      end
    end

    trait :with_expired_membership_items do
      after(:create) do |new_cart, _evaluator|
        em_item1 = create(:cart_item, :with_expired_membership_silver_f, cart: new_cart)
        new_cart.cart_items << em_item1

        em_item2 = create(:cart_item, :with_expired_membership_tuatara, cart: new_cart)
        new_cart.cart_items << em_item2
      end
    end
  end
end
