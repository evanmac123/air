FactoryGirl.define do

  factory :unnamed_user, :class => User do
    association(:demo)
    # Need to find a way to set the location of a user without creating an entirely new demo
    # association(:location)
    password  "password"
    sequence(:email) {|n| "darth_#{n}@sunni.ru" }
  end

  factory :user,  :parent => :unnamed_user do
    name "James Earl Jones"
    sample_tile_completed true

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

    trait :sample_tile_not_yet_done do
      sample_tile_completed false
    end    
  end

  factory :brand_new_user, :parent => :user do
    accepted_invitation_at { Time.now }
  end

  factory :claimed_user, :parent => :brand_new_user do
    session_count 5
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

  factory :guest_user do
    association :demo
  end

  factory :demo do
    sequence(:name) {|n| "Coolio_#{n} Board" }

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

    trait :with_public_slug do |demo|
      sequence(:public_slug) {|i| "public_#{i}"}
      is_public true
    end

    # This trait unlocks share pages
    trait :activated do |demo|
      tiles do
        [FactoryGirl.create(:multiple_choice_tile, status: Tile::ACTIVE, activated_at: Time.now, headline: "Tile #{SecureRandom.uuid}")]
      end
    end
  end

  factory :rule do
    points  2
    reply  "Yum. +2 points. Bananas help you fight cancer."
    association :demo
    association :primary_tag, :factory => :tag
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

  factory :incoming_sms do
  end

  factory :tile do
    headline {"Tile #{SecureRandom.uuid}, y'all"}
    require_images false
    association :demo
    sequence(:position){ |n| n }
    status Tile::ACTIVE
    type 'OldSchoolTile'
    question_type Tile::QUIZ
    question_subtype Tile::MULTIPLE_CHOICE

    trait :with_creator do
      association :creator, :factory => :user
    end

    trait :archived do
      status Tile::ARCHIVE
    end

    trait :active do
      status Tile::ACTIVE
    end

    trait :draft do
      status Tile::DRAFT
    end

    trait :public do
      is_public true
      status Tile::ACTIVE
      tile_tags {[FactoryGirl.create(:tile_tag)]}
    end

    trait :copyable do
      is_public true
      is_copyable true
      status Tile::ACTIVE
      tile_tags {[FactoryGirl.create(:tile_tag)]}
    end
  end

  # Simple alias of :tile to :old_school_tile
  factory :old_school_tile, parent: :tile do
  end

  factory :client_created_tile, parent: :tile do
    supporting_content "This is some extra text by the tile"
    question "Who loves ya, baby?"
    require_images true
    image {File.open(Rails.root.join "spec/support/fixtures/tiles/cov1.jpg")}
    thumbnail {File.open(Rails.root.join "spec/support/fixtures/tiles/cov1_thumbnail.jpg")}
    image_credit "by Human"
  end

  factory :keyword_tile, parent: :client_created_tile, class: KeywordTile do
    type 'KeywordTile'
    after(:create) do |tile|
      rule_value   = FactoryGirl.create(:rule_value, is_primary: true)
      rule_trigger = FactoryGirl.create(:rule_trigger, tile: tile, rule: rule_value.rule)
      tile.first_rule.update_attributes(demo_id: tile.demo_id)
    end
  end

  factory :multiple_choice_tile, parent: :client_created_tile, class: MultipleChoiceTile do
    type 'MultipleChoiceTile'
    question "Which of the following comes out of a bird?"
    points 99
    multiple_choice_answers ["Ham", "Eggs", "A V8 Buick"]
    correct_answer_index 1
  end

  factory :survey_tile, parent: :multiple_choice_tile do
    question_type Tile::SURVEY
    question_subtype Tile::MULTIPLE_CHOICE
    correct_answer_index -1
  end

  factory :action_tile, parent: :multiple_choice_tile do
    question_type Tile::ACTION
    question_subtype Tile::DO_SOMETHING
    correct_answer_index -1
  end

  factory :tile_completion do
    association :user
    association :tile

    trait :with_answer_index do
      answer_index 0
    end
  end

  factory :location do
    sequence(:name) {|n| "Awesomeville #{n}"}
    association :demo
  end

  factory :rule_trigger, :class => Trigger::RuleTrigger do
    association :rule
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

  factory :balance do |balance|
    amount 2000
    association :demo

    trait :paid do
      association :payment
    end
  end

  factory :payment do |payment|
  end

  factory :follow_up_digest_email do
    association :demo
  end

  factory :tile_tagging do
    association :tile_tag
    association :tile
  end
  
  factory :tile_tag do
    sequence(:title) {|n| "Tile Tag #{n}"}
  end
end
