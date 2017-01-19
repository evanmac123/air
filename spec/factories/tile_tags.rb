FactoryGirl.define do
  factory :tile_tag do
    association :topic
    sequence(:title) {|n| "Tile Tag #{n}"}
  end
end

