FactoryGirl.define do
  factory :topic_board do

    trait :only_board do
      board factory: :demo
    end

    trait :only_topic do
      topic factory: :topic
    end

    trait :valid do
      topic factory: :topic
      board factory: :demo
    end
  end
end
