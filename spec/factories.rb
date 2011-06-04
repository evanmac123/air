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
  factory.sequence(:sms_slug)   { |n| "jej#{n}" }
end

Factory.define :user_with_phone, :parent => :user do |factory|
  factory.phone_number {Factory.next :phone}
end

Factory.define :demo do |factory|
  factory.company_name { "Gillette" }
end

Factory.define :rule do |factory|
  factory.points { 2 }
  factory.reply  { "Yum. +2 points. Bananas help you fight cancer." }
  factory.association :demo
end

Factory.define :coded_rule do |factory|
  factory.value  { "zxcvb" }
  factory.points { 2 }
  factory.reply  { "Very good. +2 points." }
  factory.association :demo
end

Factory.define :rule_value do |factory|
  factory.sequence(:value)  {|n| "ate banana #{n}" }
  factory.association :rule
end

Factory.define :primary_value, :parent => :rule_value do |factory|
  factory.is_primary true
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

Factory.define :act do |factory|
  factory.association :user
end

Factory.define :friendship do |factory|
  factory.association :user
  factory.association :friend, :factory => :user
end

Factory.define :survey do |survey|
  survey.sequence(:name) {|n| "Survey ##{n}"}
  survey.open_at {Time.now}
  survey.close_at {Time.now + 1.day}
  survey.association :demo
end

Factory.define :survey_question do |survey_question|
  survey_question.sequence(:text) {|n| "Question ##{n} text"}
  survey_question.sequence(:index) {|n| n}
  survey_question.association :survey
end

Factory.define :survey_prompt do |survey_prompt|
  survey_prompt.sequence(:text) {|n| "Prompt ##{n} text "}
  survey_prompt.send_time {Time.now}
  survey_prompt.association :survey
end

Factory.define :survey_answer do |survey_answer|
  survey_answer.association :user
  survey_answer.association :survey_question
end

Factory.define :survey_valid_answer do |survey_valid_answer|
  survey_valid_answer.sequence(:value) {|n| n.to_s}
  survey_valid_answer.association(:survey_question)
end

Factory.define :bonus_threshold do |bonus_threshold|
  bonus_threshold.min_points 5
  bonus_threshold.max_points 7
  bonus_threshold.award 2
  bonus_threshold.association :demo
end
