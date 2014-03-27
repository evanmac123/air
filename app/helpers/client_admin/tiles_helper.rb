module ClientAdmin::TilesHelper
  def digest_email_sent_on
    @demo.tile_digest_email_sent_at.to_s(:tile_digest_email_sent_at)
  end

  def num_tiles_in_digest_email_message
    "A digest email containing #{pluralize @digest_tiles.size, 'tile'} is set to go out on "
  end

  def digest_email_sent_on_message
    @demo.tile_digest_email_sent_at.nil? ? nil : "Last digest email was sent on #{@demo.tile_digest_email_sent_at.to_s(:tile_digest_email_sent_at)}"
  end

  def no_digest_email_message
    message = "Tiles that you activate will appear here so you can share them with users in a digest email."
    message << " No new tiles have been added since the last digest email you sent on #{digest_email_sent_on}." unless @demo.tile_digest_email_sent_at.nil?
    message
  end

  def email_site_link(user, demo)
    _demo_id = demo.kind_of?(Demo) ? demo.id : demo

    email_link_hash = { protocol: email_link_protocol, host: email_link_host, demo_id: _demo_id }
    email_link_hash.merge!(user_id: user.id, tile_token: EmailLink.generate_token(user)) if user.claimed? and ! user.is_client_admin

    user.claimed? ? acts_url(email_link_hash): invitation_url(user.invitation_code, email_link_hash)
  end

  def footer_timestamp(tile, options={})
    TileFooterTimestamper.new(tile, options).footer_timestamp
  end

  # We display a different heading if the schmuck... er, customer, didn't interact with any of the tiles in the first digest email
  def digest_email_heading_begin
    @follow_up_email ? 'Did you forget to check out your' : 'Check out your'
  end

  def digest_email_heading_end
    @follow_up_email ? '?' : '!'
  end

  def default_follow_up_day
    FollowUpDigestEmail::DEFAULT_FOLLOW_UP[Date::DAYNAMES[Date.today.wday]]
  end
<<<<<<< HEAD
    
  def activate
    current_user.demo.tiles.archived.update_all(status: Tile::ACTIVE)
  end

  def tile_types
    {
      "Action" => {
        "Do something".parameterize("_") => {
          name: "Do something",
          question: "Points for taking action",
          answers: ["I did it"] 
        },
        "Read Tile".parameterize("_") => {
          name: "Read Tile",
          question: "Points for reading tile",
          answers: ["I read it"]
        },
        "Read Article".parameterize("_") => {
          name: "Read Article",
          question: "Points for reading article",
          answers: ["I read it"]
        },
        "Share On Social Media".parameterize("_") => {
          name: "Share On Social Media",
          question: "Points for sharing on social media (e.g., Facebook, Twitter)",
          answers: ["I shared"] 
        },
        "Visit Web Site".parameterize("_") => {
          name: "Visit Web Site",
          question: "Points for visiting web site",
          answers: ["I visited"] 
        },
        "Watch Video".parameterize("_") => {
          name: "Watch Video",
          question: "Points for watching video",
          answers: ["I watched"] 
        },
        "Custom...".parameterize("_") => {
          name: "Custom...",
          question: "Points for FILL IN",
          answers: ["FILL IN ACTION"]
        }
      },

      "Quiz" => {
        "True / False".parameterize("_") => {
          name: "True / False",
          question: "Fill In Statement",
          answers: ["True", "False"]
        },
        "Multiple Choice".parameterize("_") => {
          name: "Multiple Choice",
          question: "Ask a question",
          answers: ["Add Answer Option", "Add Answer Option"]
        }
      },

      "Survey" => {
        "Multiple Choice".parameterize("_") => {
          name: "Multiple Choice",
          question: "Select one of the following options",
          answers: ["Add Answer Option", "Add Answer Option"]
        },
        "RSVP to event".parameterize("_") => {
          name: "RSVP to event",
          question: "Will you be attending?",
          answers: ["Yes", "No", "Maybe"]
        }
      }
    }
  end

  def tile_type_tooltips
    {
      "Action" => "User confirms doing something",
      "Quiz" => "Ask a question with one right answer",
      "Survey" => "Ask a question, user can select one answer"
    }
  end
end
