FactoryBot.define do
  factory :population_segment do
    association :demo
    sequence(:name) {|n| "test population_#{n}" }
  end
end
