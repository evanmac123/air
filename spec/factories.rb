Factory.sequence :email do |n|
  "user#{n}@example.com"
end

Factory.sequence :phone do |n|
  "+1" + (4155550000 + n).to_s
end







FactoryGirl.define do
  
  factory :unnamed_user, :class => User do 
    association(:demo)
    association(:location)
    email FactoryGirl.generate :email 
    password  "password" 
  end
  
  
  factory :tutorial do
    association :user
  end
  
  factory :inactive_tutorial, :parent => :tutorial do
    ended_at  2.days.ago 
  end
  
  factory :user,  :parent => :unnamed_user do 
    name                  "James Earl Jones" 
    sequence(:email, User.next_id) {|n| "darth_#{n}@vader.com" }
  end
  
  factory :brand_new_user, :parent => :user do 
    accepted_invitation_at Time.now
  end  
  
  factory :claimed_user, :parent => :brand_new_user do 
    session_count 5
    association :tutorial, :factory => :inactive_tutorial
  end
  
  factory :user_with_phone, :parent => :claimed_user do 
    phone_number FactoryGirl.generate :phone
  end
  
  factory :site_admin, :parent => :claimed_user do
    name {"Sylvester McAdmin"}
    is_site_admin {true}
  end
  
  factory :demo do 
    sequence(:name, Demo.next_id) {|n| "Coolio_#{n}" }
  end
  
  factory :rule do
    points { 2 }
    reply  { "Yum. +2 points. Bananas help you fight cancer." }
    association :demo
    association :primary_tag, :factory => :tag
  end
  
  factory :coded_rule do
    value  { "zxcvb" }
    points { 2 }
    reply  { "Very good. +2 points." }
    association :demo
  end

  factory :rule_value do
    sequence(:value)  {|n| "ate banana #{n}" }
    association(:rule)
  end

  factory :primary_value, :parent => :rule_value do
    is_primary true
  end

  factory :forbidden_rule_value, :class => RuleValue do
    sequence(:value) { |n| "drank beer #{n}" }
  end

  factory :tag do
    description "A short description"
    sequence(:name) {|n| "Cool word #{n}"}
  end

  factory :label do
    association(:rule)
    association(:tag)
  end

  factory :key do
    sequence(:name) { |n| "ate_#{n}" }
  end

  factory :bad_message do
    phone_number FactoryGirl.generate :phone 
    received_at  Time.now 
  end

  factory :new_bad_message, :parent => :bad_message do
    is_new true
  end

  factory :watchlisted_bad_message, :parent => :bad_message do
    after_create do |bad_message|
      bad_message.update_attributes(:is_new => false, :on_watch_list => true)
    end
  end

  factory :bad_message_reply do
    association :sender, :factory => :user
    association :bad_message
  end

  factory :act do
    association :user
  end

  factory :act_with_rule, :parent => :act do
    association :rule
  end

  factory :friendship do
    association :user
    association :friend, :factory => :user
  end

  factory :accepted_friendship, :parent => :friendship do
    state 'accepted'
  end
  
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

Factory.define :level do |level|
  level.sequence(:name) {|n| "Level" + n.to_s}
  level.sequence(:threshold) {|n| 30 * n}
  level.association :demo
end

Factory.define :skin do |skin|
  skin.association :demo
end

Factory.define :goal do |goal|
  goal.sequence(:name) {|n| "Number #{n} Goal"}
  goal.association :demo
end

Factory.define :email_command do |email_command|
  email_command.status EmailCommand::Status::UNKNOWN_EMAIL
end

Factory.define :timed_bonus do |timed_bonus|
  timed_bonus.expires_at {Time.now + 24.hours}
  timed_bonus.points {10}
  timed_bonus.association :user
  timed_bonus.association :demo
end

Factory.define :bad_word do |bad_word|
  bad_word.value {"goshdarnit"}
  bad_word.association :demo
end

Factory.define :task do |task|
  task.name "Roast chestnuts"
  task.association :demo
  task.sequence(:identifier) {|n| "Identifier#{n}"}
  
end

Factory.define :task_suggestion do |task_suggestion|
  task_suggestion.association :user
  task_suggestion.association :task
end

Factory.define :self_inviting_domain do |self_inviting_domain|
  self_inviting_domain.sequence(:domain) {|n| "example#{n}.com"}
  self_inviting_domain.association :demo
end

Factory.define :incoming_sms do
end

Factory.define :location do |location|
  location.sequence(:name) {|n| "Plant #{n}"}
  location.association :demo
end

Factory.define :rule_trigger, :class => Trigger::RuleTrigger do |rule_trigger|
  rule_trigger.association :rule
  rule_trigger.association :task
end

Factory.define :survey_trigger, :class => Trigger::SurveyTrigger do |survey_trigger|
  survey_trigger.association :survey
  survey_trigger.association :task
end

Factory.define :demographic_trigger, :class => Trigger::DemographicTrigger do |demographic_trigger|
  demographic_trigger.association :task
end

Factory.define :characteristic do |characteristic|
  characteristic.sequence(:name) {|n| "Char_#{n}"}
  characteristic.sequence(:description) {|n| "Desc_#{n}"}
  characteristic.allowed_values {%w(Foo Bar Baz)}
end

Factory.define :demo_specific_characteristic, :parent => :characteristic do |demo_specific_characteristic|
  demo_specific_characteristic.association :demo
end
