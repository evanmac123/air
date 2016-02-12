FactoryGirl.define do

  factory :unnamed_user, :class => User do
    association(:demo)
    association :user_intro
    # Need to find a way to set the location of a user without creating an entirely new demo
    # association(:location)
    password  "password"
    sequence(:email) {|n| "darth_#{n}@sunni.ru" }
    #submit_tile_intro_seen true
    suggestion_box_intro_seen true
    user_submitted_tile_intro_seen true
    manage_access_prompt_seen true
    trait :with_explore_intro do
      user_intro { FactoryGirl.create :user_intro, explore_intro_seen: false }
    end
  end

  factory :user,  :parent => :unnamed_user do
    name "James Earl Jones"
    sample_tile_completed true

    trait :claimed do
      accepted_invitation_at Time.now
    end

    # This trait is, strictly speaking, redundant, but some tests are easier
    # to read if we say this explicitly.
    trait :unclaimed do
      accepted_invitation_at nil
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

    trait :with_tickets do
      tickets 3
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
    share_section_intro_seen true
  end

  factory :client_admin, :parent => :claimed_user do
    name            "Bo Diddley"
    is_client_admin true
    share_section_intro_seen true
  end

  factory :guest_user do
    association :demo
  end

  factory :demo do
    sequence(:name) {|n| "Coolio_#{n} Board" }

    trait :with_email do
      sequence(:email) {|n| "demo_#{n}@ourairbo.com"}
    end

    trait :with_tickets do
      # Currently a no-op since uses_tickets is, for the moment, hardcoded to
      # true in demo.rb
      #uses_tickets true
    end

    trait :with_phone_number do
      sequence(:phone_number) {|i| "+" + (16172222222 + 1).to_s}
    end

    sequence(:public_slug) {|i| "public_#{i}"}

    trait :with_public_slug do |demo|
      is_public true
    end

    # This trait unlocks share pages
    trait :activated do |demo|
      tiles do
        [FactoryGirl.create(:multiple_choice_tile, status: Tile::ACTIVE, activated_at: Time.now, headline: "Tile #{SecureRandom.uuid}")]
      end
    end

    trait :with_turned_off_onboarding do
      turn_off_admin_onboarding true
    end

    trait :paid do
      is_paid true
    end

    trait :parent do
      is_parent true
      is_public true
    end
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

  factory :friendship do
    association :user
    association :friend, :factory => :user
  end

  factory :accepted_friendship, :parent => :friendship do
    state 'accepted'
  end

  factory :email_command do
    status EmailCommand::Status::UNKNOWN_EMAIL
  end

  factory :incoming_sms do
  end

  factory :tile do
    headline {"Tile #{SecureRandom.uuid}, y'all"}
    require_images false
    remote_media_url "/images/avatars/thumb/missing.png"
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

    trait :user_draft do
      status Tile::USER_DRAFT
    end

    trait :user_submitted do
      status Tile::USER_SUBMITTED
      association :creator, factory: :user
    end

    trait :ignored do
      status Tile::IGNORED
    end

    trait :sharable do
      is_sharable true
    end

    trait :public do
      is_sharable true
      is_public true
      status Tile::ACTIVE
      tile_tags {[FactoryGirl.create(:tile_tag)]}
    end

    trait :copyable do
      is_sharable true
      is_public true
      is_copyable true
      status Tile::ACTIVE
      tile_tags {[FactoryGirl.create(:tile_tag)]}
    end

    trait :user_drafted do
      status Tile::USER_DRAFT
      association :creator, factory: :user
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

  factory :multiple_choice_tile, parent: :client_created_tile, class: MultipleChoiceTile do
    type 'MultipleChoiceTile'
    question "Which of the following comes out of a bird?"
    points 99
    #TODO fix this so that the tile uses the native multiple_choice_answers_field
    #answers ["Ham", "Eggs", "A V8 Buick"]
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
    question_subtype Tile::TAKE_ACTION
    correct_answer_index -1
  end

  factory :sharable_and_public_tile, parent: :multiple_choice_tile do
    is_public true
    is_sharable true
    tile_taggings do
      [FactoryGirl.create(:tile_tagging)]
    end
  end

  factory :tile_image do
    image {File.open(Rails.root.join "spec/support/fixtures/tiles/cov2.jpg")}
    thumbnail {File.open(Rails.root.join "spec/support/fixtures/tiles/cov2_thumbnail.jpg")}
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

  factory :follow_up_digest_email do
    association :demo
  end

  factory :tile_tagging do
    association :tile_tag
    association :tile
  end

  factory :tile_tag do
    association :topic
    sequence(:title) {|n| "Tile Tag #{n}"}
  end

  factory :topic do
    sequence(:name) {|n| "Good Topic #{n}"}
  end

  factory :billing_information do
    expiration_month "2"
    expiration_year  "2019"
    last_4           "9042"
    customer_token   "cus_fake"
    card_token       "card_fake"
    issuer           "American Excess"

    association :user
  end

  factory :raffle do
    association :demo
    starts_at DateTime.now.change({:hour => 0 , :min => 0 , :sec => 0 })
    ends_at DateTime.now.change({:hour => 0 , :min => 0 , :sec => 0 }) + 8.days - 1.minute
    prizes ["First Prize", "Second Prize"]
    other_info "Play raffles - it's fun"

    trait :set_up do
      status Raffle::SET_UP
    end

    trait :live do
      status Raffle::LIVE
    end

    trait :pick_winners do
      status Raffle::PICK_WINNERS
    end

    trait :picked_winners do
      status Raffle::PICKED_WINNERS
    end
  end

  factory :user_in_raffle_info do
    association :user
    association :raffle
    start_showed false
    finish_showed false
    in_blacklist false
    is_winner false
  end

  factory :potential_user do
    sequence(:email) {|n| "potential_#{n}@user.com" }
    invitation_code "MyString"
    association(:demo)
  end

  factory :tile_viewing do
    association :tile
    association :user
  end

  factory :organization  do

    trait :complete do
      sequence(:name){|n| "Client-#{n}"}
      sales_channel "Direct"
      num_employees   5000
    end

   trait :with_active_contract do
      after(:create) do |org, evaluator|
        create(:contract, :complete, :active, organization: org)
      end
   end

    trait :with_contracts do
      complete
      after(:create) do |org, evaluator|
        create(:contract, :complete, organization: org, start_date: '2012-01-01', end_date: '2012-12-31' )
        create(:contract, :complete, organization: org, start_date: '2013-01-01', end_date: '2013-12-31' )
        create(:contract, :complete, organization: org, start_date: '2014-01-01', end_date: '2014-12-31' )
      end
    end

  end

  factory :contract do
    sequence(:name) {|n|"Contract-#{n}"}

    trait :complete do
      association :organization, factory: [:organization, :complete]
      arr  60000
      amt_booked  5000
      start_date '2012-01-01'
      end_date '2012-12-31'
      term  12
      plan  "engage"
      max_users 100
    end

    trait :active do
      start_date  Date.today 
      end_date  1.year.from_now 
    end

    factory :upgrade , class: Contract do
      complete
      trait :with_parent do
        association :parent_contract, factory: [:contract, :complete]
      end
    end
  end

  factory :user_intro do
    explore_intro_seen true
  end
end
