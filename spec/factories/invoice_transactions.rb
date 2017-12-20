# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :invoice_transaction do
    invoice nil
    type_cd 1
  end
end
