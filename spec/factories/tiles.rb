FactoryBot.define do
  factory :tile do
    headline {"Tile #{SecureRandom.uuid}, y'all"}
    require_images false
    association :demo
    sequence(:position){ |n| n }
    supporting_content "This is some extra text by the tile"
    status Tile::ACTIVE
    question "Who loves ya, baby?"
    question_type Tile::QUIZ
    question_subtype Tile::MULTIPLE_CHOICE
    remote_media_url "/images/cov1.jpg"

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
    end

    trait :copyable do
      is_sharable true
      is_public true
      status Tile::ACTIVE
    end

    trait :user_drafted do
      status Tile::USER_DRAFT
      association :creator, factory: :user
    end
  end

  factory :client_created_tile, parent: :tile do
    image {File.open("#{Rails.root}/spec/support/fixtures/tiles/cov1.jpg")}
    thumbnail {File.open("#{Rails.root}/spec/support/fixtures/tiles/cov1_thumbnail.jpg")}
    image_credit "by Human"
  end

  factory :multiple_choice_tile, parent: :client_created_tile do
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
    correct_answer_index (-1)
  end

  factory :action_tile, parent: :multiple_choice_tile do
    question_type Tile::ACTION
    question_subtype Tile::TAKE_ACTION
    correct_answer_index (-1)
  end

  factory :sharable_and_public_tile, parent: :multiple_choice_tile do
    is_public true
    is_sharable true
  end


end
