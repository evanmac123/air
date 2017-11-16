FactoryGirl.define do
  factory :unnamed_user, :class => User do
    association(:demo)
    association :user_intro
    # Need to find a way to set the location of a user without creating an entirely new demo
    password  "password"
    sequence(:email) {|n| "darth_#{n}@sunni.ru" }
    suggestion_box_intro_seen true
    user_submitted_tile_intro_seen true
    manage_access_prompt_seen true
  end

  factory :user,  :parent => :unnamed_user do
    name "James Earl Jones"

    trait :claimed do
      accepted_invitation_at Time.current
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

    trait :with_tickets do
      tickets 3
    end
  end

  factory :brand_new_user, :parent => :user do
    accepted_invitation_at { Time.current }
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
end
