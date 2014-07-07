module ClientAdmin::TilesHelper
  def digest_email_sent_on
    @demo.tile_digest_email_sent_at.to_s(:tile_digest_email_sent_at)
  end

  def num_tiles_in_digest_email_message
    "A digest email containing #{pluralize @digest_tiles.size, 'tile'} is set to go out on "
  end

  def digest_email_sent_on_message
    @demo.tile_digest_email_sent_at.nil? ? nil : "Last tiles sent on #{@demo.tile_digest_email_sent_at.to_s(:tile_digest_email_sent_at)}"
  end

  def no_digest_email_message
    message = "Tiles that you activate will appear here so you can share them with users in a digest email."
    message << " No new tiles have been added since the last digest email you sent on #{digest_email_sent_on}." unless @demo.tile_digest_email_sent_at.nil?
    message
  end

  def email_site_link(user, demo, is_preview = false, email_type = "")
    _demo_id = demo.kind_of?(Demo) ? demo.id : demo

    email_link_hash = is_preview ? {demo_id: _demo_id} : { protocol: email_link_protocol, host: email_link_host, demo_id: _demo_id, email_type: email_type }
    email_link_hash.merge!(user_id: user.id, tile_token: EmailLink.generate_token(user)) if user.claimed? and ! user.is_client_admin

    (is_preview || user.claimed?) ? acts_url(email_link_hash): invitation_url(user.invitation_code, email_link_hash)
  end

  def footer_timestamp(tile, options={})
    TileFooterTimestamper.new(tile, options).footer_timestamp
  end
  
  def tile_time_ago(tile,options={})
    TileFooterTimestamper.new(tile, options).footer_timestamp_ago
  end

  # We display a different heading if the schmuck... er, customer, didn't interact with any of the tiles in the first digest email
  def digest_email_heading
    @follow_up_email ? "Don't miss your new tiles" : 'Your New Tiles Are Here!'
  end

  def default_follow_up_day
    FollowUpDigestEmail::DEFAULT_FOLLOW_UP[Date::DAYNAMES[Date.today.wday]]
  end
    
  def activate
    current_user.demo.tiles.archived.update_all(status: Tile::ACTIVE)
  end

  def tile_types
    {
      Tile::ACTION => {
        Tile::DO_SOMETHING => {
          name: "Do something",
          question: "Points for taking action",
          answers: ["I did it"] 
        },
        Tile::READ_TILE => {
          name: "Read tile",
          question: "Points for reading tile",
          answers: ["I read it"]
        },
        Tile::READ_ARTICLE => {
          name: "Read Article",
          question: "Points for reading article",
          answers: ["I read it"]
        },
        Tile::SHARE_ON_SOCIAL_MEDIA => {
          name: "Share On Social Media",
          question: "Points for sharing on social media (e.g., Facebook, Twitter)",
          answers: ["I shared"] 
        },
        Tile::VISIT_WEB_SITE => {
          name: "Visit Web Site",
          question: "Points for visiting web site",
          answers: ["I visited"] 
        },
        Tile::WATCH_VIDEO => {
          name: "Watch Video",
          question: "Points for watching video",
          answers: ["I watched"] 
        },
        Tile::CUSTOM => {
          name: "Custom...",
          question: "Points for taking an action",
          answers: ["Add Action"]
        }
      },

      Tile::QUIZ => {
        Tile::TRUE_FALSE.parameterize("_") => {
          name: "True / False",
          question: "Fill In Statement",
          answers: ["True", "False"]
        },
        Tile::MULTIPLE_CHOICE.parameterize("_") => {
          name: "Multiple Choice",
          question: "Ask a question",
          answers: ["Add Answer Option", "Add Answer Option"]
        }
      },

      Tile::SURVEY => {
        Tile::MULTIPLE_CHOICE.parameterize("_") => {
          name: "Multiple Choice",
          question: "Add Question",
          answers: ["Add Answer Option", "Add Answer Option"]
        },
        Tile::RSVP_TO_EVENT.parameterize("_") => {
          name: "RSVP to event",
          question: "Will you be attending?",
          answers: ["Yes", "No", "Maybe"]
        }
      }
    }
  end

  def update_tile_types tile_types, tile_builder
    old_tile_type(tile_builder.tile) unless tile_builder.tile.question_type
    type = tile_builder.tile.question_type 
    subtype = tile_builder.tile.question_subtype
    question = tile_builder.tile.question
    answers = tile_builder.tile.multiple_choice_answers
    correct = tile_builder.tile.correct_answer_index
    tile_types[type][subtype][:question] = question
    tile_types[type][subtype][:answers] = answers
    tile_types[type][subtype][:correct] = correct
    tile_types
  end

  def old_tile_type tile
    tile.question_type =  tile.is_survey? ? Tile::SURVEY : Tile::QUIZ
    tile.question_subtype = Tile::MULTIPLE_CHOICE
  end
end
