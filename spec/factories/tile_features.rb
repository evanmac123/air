# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :tile_feature do
    sequence(:name) { |n| "Tile Feature #{n}" }
    sequence(:rank) { |n| n }
  end
end
