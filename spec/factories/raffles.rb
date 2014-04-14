# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :raffle do
    starts_at "2014-04-10 15:25:26"
    ends_at "2014-04-10 15:25:26"
    prizes "MyText"
    other_info "MyText"
    status "MyString"
  end
end
