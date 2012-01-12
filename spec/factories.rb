Factory.sequence :email do |n|
  "user#{n}@example.com"
end

Factory.sequence :phone do |n|
  "+1" + (4155550000 + n).to_s
end

Factory.define :unnamed_user, :class => User do |factory|
  factory.association(:demo)
  factory.association(:location)
  factory.email                 { Factory.next :email }
  factory.password              { "password" }
  factory.password_confirmation { "password" }
end

Factory.define :user,  :parent => :unnamed_user do |factory|
  factory.name                  { "James Earl Jones" }
  # set_slugs runs if user has a name, so there is no need to create slugs here
  # factory.sequence(:sms_slug)   { |n| "jej#{n}" }
  # factory.sequence(:slug)       { |n| "jej#{n}" }
end

Factory.define :claimed_user, :parent => :user do |factory|
  factory.accepted_invitation_at {Time.now}
end

Factory.define :user_with_phone, :parent => :claimed_user do |factory|
  factory.phone_number {Factory.next :phone}
end

Factory.define :site_admin, :parent => :user do |factory|
  factory.name {"Joe-Bob McAdmin"}
  factory.is_site_admin {true}
end

Factory.define :demo do |factory|
  factory.company_name { "Gillette" }
end

Factory.define :rule do |factory|
  factory.points { 2 }
  factory.reply  { "Yum. +2 points. Bananas help you fight cancer." }
  factory.association :demo
  factory.association :primary_tag, :factory => :tag
end

Factory.define :coded_rule do |factory|
  factory.value  { "zxcvb" }
  factory.points { 2 }
  factory.reply  { "Very good. +2 points." }
  factory.association :demo
end

Factory.define :rule_value do |factory|
  factory.sequence(:value)  {|n| "ate banana #{n}" }
  factory.association(:rule)
end

Factory.define :primary_value, :parent => :rule_value do |factory|
  factory.is_primary true
end

Factory.define :forbidden_rule_value, :class => RuleValue do |factory|
  factory.sequence(:value) { |n| "drank beer #{n}" }
end

Factory.define :tag do |factory|
  factory.description {"A short description"}
  factory.sequence(:name) {|n| "Cool word #{n}"}
end

Factory.define :label do |factory|
  factory.association(:rule)
  factory.association(:tag)
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

Factory.define :accepted_friendship, :parent => :friendship do |factory|
  factory.state 'accepted'
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

Factory.define :level do |level|
  level.name "Level"
  level.sequence(:threshold) {|n| n}
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

Factory.define :suggested_task do |suggested_task|
  suggested_task.name "Roast chestnuts"
  suggested_task.association :demo
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
  rule_trigger.association :suggested_task
end

Factory.define :survey_trigger, :class => Trigger::SurveyTrigger do |survey_trigger|
  survey_trigger.association :survey
  survey_trigger.association :suggested_task
end

Factory.define :demographic_trigger, :class => Trigger::DemographicTrigger do |demographic_trigger|
  demographic_trigger.association :suggested_task
end
