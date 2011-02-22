Factory.sequence :email do |n|
  "user#{n}@example.com"
end

Factory.sequence :phone do |n|
  "+1" + (4155550000 + n).to_s
end

Factory.define :user do |factory|
  factory.association(:demo)
  factory.name                  { "James Earl Jones" }
  factory.email                 { Factory.next :email }
  factory.password              { "password" }
  factory.password_confirmation { "password" }
end

Factory.define :demo do |factory|
  factory.company_name { "Gillette" }
end

Factory.define :rule do |factory|
  factory.association(:key)
  factory.value  { "banana" }
  factory.points { 2 }
  factory.reply  { "Yum. +2 points. Bananas help you fight cancer." }
end

Factory.define :key do |factory|
  factory.sequence(:name) { |n| "ate_#{n}" }
end
