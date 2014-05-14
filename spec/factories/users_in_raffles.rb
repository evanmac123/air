# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :users_in_raffle do
    user_id 1
    raffle_id 1
    start_showed false
    finish_showed false
    in_blacklist false
    is_winner false
  end
end
