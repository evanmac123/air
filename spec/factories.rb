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

Factory.define :user_with_phone, :parent => :user do |factory|
  factory.phone_number {Factory.next :phone}
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

Factory.define :coded_rule do |factory|
  factory.value  { "zxcvb" }
  factory.points { 2 }
  factory.reply  { "Very good. +2 points." }
end

Factory.define :key do |factory|
  factory.sequence(:name) { |n| "ate_#{n}" }
end

Factory.define :bad_message do |factory|
  factory.phone_number { Factory.next :phone }
  factory.received_at  { Time.now }
end

Factory.define :new_bad_message, :parent => :bad_message do |factory|
  factory.is_new true
end

Factory.define :watchlisted_bad_message, :parent => :bad_message do |factory|
  factory.after_create do |bad_message|
    bad_message.update_attributes(:is_new => false, :on_watch_list => true)
  end
end

Factory.define :bad_message_reply do |factory|
  factory.association :sender, :factory => :user
  factory.association :bad_message
end
