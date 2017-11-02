FactoryGirl.define do
  factory :board_membership do
    demo
    user factory: :user

    trait :claimed do
      joined_board_at Time.current
    end
  end
end
