FactoryBot.define do
  factory :cart_item do
    kind {"membership"}
    later {false}
    available {true}
    association :chicago_contact
    association :cart

    transient do
      membership { create(:membership, :adult)}
    end

    after(:build) do |cart_item, evaluator|
      cart_item.membership = evaluator.membership
    end
    item_name { membership.name }
    item_price_cents {membership.price_cents}


    trait :with_kidit do
      transient do
        membership { create(:membership, :kidit)}
      end
      after(:build) do |cart_item, evaluator|
        cart_item.membership = evaluator.membership
      end
      item_name { membership.name }
      item_price_cents {membership.price_cents}
    end

    trait :with_ya do
      transient do
        membership { create(:membership, :ya)}
      end
      after(:build) do |cart_item, evaluator|
        cart_item.membership = evaluator.membership
      end
      item_name { membership.name }
      item_price_cents { membership.price_cents }
    end

    trait :with_supporting do
      transient do
        membership { create(:membership, :supporting)}
      end
      after(:build) do |cart_item, evaluator|
        cart_item.membership = evaluator.membership
      end
      item_name { membership.name }
      item_price_cents { membership.price_cents }
    end

    trait :with_expired_membership_tuatara do
      transient do
        membership { create(:membership, :tuatara)}
      end
      after(:build) do |cart_item, evaluator|
        cart_item.membership = evaluator.membership
      end
      item_name { membership.name }
      item_price_cents { membership.price_cents }
    end

    trait :with_expired_membership_silver_f do
      transient do
        membership { create(:membership, :silver_fern)}
      end
      after(:build) do |cart_item, evaluator|
        cart_item.membership = evaluator.membership
      end
      item_name { membership.name }
      item_price_cents { membership.price_cents }
    end

    trait :saved_for_later do
      later {true}
    end

    trait :unavailable do
      before(:create) do |cart_item, evaluator|
        cart_item.available = false;
      end
    end

    trait :price_altered do
      before(:create) do |cart_item, evaluator|
        cart_item.item_price_cents += 100
      end
    end

    trait :name_altered do
      before(:create) do |cart_item, evaluator|
        cart_item.item_name = "altered"
      end
    end
  end
end
