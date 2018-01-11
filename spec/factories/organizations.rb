FactoryBot.define do
  factory :organization  do
    sequence(:name) {|n| "Airbo Org #{n}" }

    trait :complete do
      sequence(:name){|n| "Client-#{n}"}
      num_employees   5000
    end
  end
end
