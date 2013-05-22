FactoryGirl.define do
  
  factory :unnamed_user, :class => User do 
    association(:demo)
    # Need to find a way to set the location of a user without creating an entirely new demo
    # association(:location)
    password  "password" 
    sequence(:email) {|n| "darth_#{n}@sunni.ru" }
  end
  
  
  factory :tutorial do
    association :user
  end
  
  factory :inactive_tutorial, :parent => :tutorial do
    ended_at  2.days.ago 
  end
  
  factory :user,  :parent => :unnamed_user do 
    name "James Earl Jones"

    trait :claimed do
      accepted_invitation_at Time.now
    end

    trait :with_phone_number do
      sequence(:phone_number) {|n| "+1#{4442220000 + n}" }
    end

    trait :with_game_referrer do
      association :game_referrer, :factory => :user
    end

    trait :with_location do
      association :location
    end
  end

  factory :brand_new_user, :parent => :user do 
    accepted_invitation_at { Time.now }
  end  
  
  factory :claimed_user, :parent => :brand_new_user do 
    session_count 5
    association :tutorial, :factory => :inactive_tutorial
  end
  
  factory :user_with_phone, :parent => :claimed_user do 
    sequence(:phone_number) {|n| "+1#{4442220000 + n}" }
    notification_method "both"
  end
  
  factory :site_admin, :parent => :claimed_user do
    name          "Sylvester McAdmin"
    is_site_admin true
  end
  
  factory :client_admin, :parent => :claimed_user do
    name            "Bo Diddley"
    is_client_admin true
  end

  factory :demo do
    sequence(:name) {|n| "Coolio_#{n}" }

    trait :with_email do
      sequence(:email) {|n| "demo_#{n}@example.com"}
    end

    trait :with_tickets do
      # Currently a no-op since uses_tickets is, for the moment, hardcoded to
      # true in demo.rb
      #uses_tickets true
    end

    trait :with_phone_number do
      sequence(:phone_number) {|i| "+" + (16172222222 + 1).to_s}
    end

    tile_digest_email_sent_at { Time.now }
  end
  
  factory :rule do
    points  2
    reply  "Yum. +2 points. Bananas help you fight cancer."
    association :demo
    association :primary_tag, :factory => :tag
  end
  
  factory :coded_rule do
    value   "zxcvb"
    points  2
    reply   "Very good. +2 points."
    association :demo
  end

  factory :rule_value do
    sequence(:value)  {|n| "ate banana #{n}" }
    association(:rule)
  end

  factory :primary_value, :parent => :rule_value do
    is_primary true
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
    phone_number "+14155551212"
    received_at  { Time.now }
  end

  factory :new_bad_message, :parent => :bad_message do
    is_new true
  end

  factory :watchlisted_bad_message, :parent => :bad_message do
    after(:create) do |bad_message|
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


  factory :survey do
    sequence(:name) {|n| "Survey ##{n}"}
    open_at {Time.now}
    close_at {Time.now + 1.day}
    association :demo
  end

  factory :survey_question do
    sequence(:text) {|n| "Question ##{n} text"}
    sequence(:index) {|n| n}
    association :survey
  end

  factory :survey_prompt do
    sequence(:text) {|n| "Prompt ##{n} text "}
    send_time {Time.now}
    association :survey
  end

  factory :survey_answer do
    association :user
    association :survey_question
  end

  factory :survey_valid_answer do
    sequence(:value) {|n| n.to_s}
    association(:survey_question)
  end

  factory :skin do
    association :demo
  end

  factory :goal do
    sequence(:name) {|n| "Number #{n} Goal"}
    association :demo
  end

  factory :email_command do
    status EmailCommand::Status::UNKNOWN_EMAIL
  end

  factory :timed_bonus do
    expires_at {Time.now + 24.hours}
    points 10
    association :user
    association :demo
  end

  factory :bad_word do
    value "goshdarnit"
    association :demo
  end
  factory :incoming_sms do
  end

  factory :tile do
    headline "Riceburners Back in Style"
    require_images false
    association :demo
    sequence(:position){ |n| n }
  end

  factory :tile_completion do
    association :user
    association :tile
  end

  factory :location do
    sequence(:name) {|n| "Plant #{n}"}
    association :demo
  end

  factory :rule_trigger, :class => Trigger::RuleTrigger do
    association :rule
    association :tile
  end

  factory :survey_trigger, :class => Trigger::SurveyTrigger do
    association :survey
    association :tile
  end

  factory :characteristic do 
    sequence(:name) {|n| "Char_#{n}"}
    sequence(:description) {|n| "Desc_#{n}"}
    datatype Characteristic::DiscreteType
    allowed_values %w(Foo Bar Baz)

    trait :discrete do
    end

    trait :demo_specific do
      association :demo
    end

    trait :number do
      datatype Characteristic::NumberType
      allowed_values nil
    end

    trait :date do
      datatype Characteristic::DateType
      allowed_values nil
    end

    trait :boolean do
      datatype Characteristic::BooleanType
      allowed_values nil
    end

    trait :time do
      datatype Characteristic::TimeType
      allowed_values nil
    end

    factory :demo_specific_characteristic, traits: [:demo_specific]
  end

  factory :claim_state_machine do |claim_state_machine|
    claim_state_machine.states { {} }
    claim_state_machine.association :demo
  end

  factory :custom_invitation_email do |custom_invitation_email|
    association :demo
  end

  factory :peer_invitation do |peer_invitation|
    association :inviter, :factory => :user
    association :invitee, :factory => :user
  end
end
