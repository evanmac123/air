# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :tiles_digest do
    sender nil
    recipient_count 1
    custom_headline "MyText"
    custom_message "MyText"
    subject "MyText"
    alt_subject "MyText"
  end
end
