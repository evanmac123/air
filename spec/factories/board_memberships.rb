FactoryGirl.define do
  factory :board_membership do
    demo
    user

    trait :claimed do
      joined_board_at Time.now
    end
  end
end
