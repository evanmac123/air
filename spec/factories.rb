FactoryGirl.define do
  #USER


  # factory :board_membership do
  #   demo { FactoryGirl.create :demo }
  #   user { FactoryGirl.create :user, demo: demo }
  #   association :location
  # end

  #DEMO
  factory :demo do
    association :organization
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

      after(:create) do |demo, evaluator|
        FactoryGirl.create(:multiple_choice_tile, status: Tile::ACTIVE, demo: demo,  activated_at: Time.now, headline: "Tile #{SecureRandom.uuid}")
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

    trait :with_dependent_board do
      association :dependent_board, factory: :demo
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
    association :primary_user, factory: :user
  end

  factory :tile_viewing do
    association :tile
    association :user
  end

  factory :contract do
    sequence(:name) {|n|"Contract-#{n}"}

    trait :complete do
      association :organization, factory: [:organization, :complete]
      arr  60000
      amt_booked  5000
      start_date '2012-01-01'
      end_date '2012-12-31'
      cycle Contract::ANNUAL
      plan  "engage"
      max_users 100
    end

    trait :custom do
      cycle Contract::CUSTOM
    end

    trait :canceled do
      auto_renew false
    end

    trait :custom_valid do
      custom
      term 9
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
    explore_preview_copy_seen true
  end

  factory :user_settings_change_log do
    association :user
    email "new_email@mail.com"
    email_token "86f7e437faa5a7fce15d1ddcb9eaeaea377667b8"
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
end
