module ClientAdmin::TilesHelper
  include EmailHelper

  def digest_email_sent_on
    @demo.tile_digest_email_sent_at.to_s(:tile_digest_email_sent_at)
  end

  def num_tiles_in_digest_email_message
    "A digest email containing #{pluralize @digest_tiles.size, 'tile'} is set to go out on "
  end

  def digest_email_sent_on_message
    @demo.tile_digest_email_sent_at.nil? ? nil : "Last tiles sent on #{@demo.tile_digest_email_sent_at.to_s(:tile_digest_email_sent_at)}"
  end

  def email_site_link(user, demo, is_preview = false, email_type = "")
    _demo_id = demo.kind_of?(Demo) ? demo.id : demo

    email_link_hash = is_preview ? {demo_id: _demo_id} : { protocol: email_link_protocol, host: email_link_host, demo_id: _demo_id, email_type: email_type }
    email_link_hash.merge!(user_id: user.id, tile_token: EmailLink.generate_token(user)) if user.claimed? and ! user.is_client_admin

    (is_preview || user.claimed?) ? acts_url(email_link_hash): invitation_url(user.invitation_code, email_link_hash)
  end

  def activate
    current_user.demo.tiles.archive.update_all(status: Tile::ACTIVE)
  end

  def set_tile_types(tile)
    tile.new_record? ? tile_types : update_tile_types(tile_types, tile)
  end

  def tile_types
    {
      Tile::ACTION => {
        Tile::TAKE_ACTION => {
          name: "Take Action",
          question: "Points for taking action",
          answers: ["I did it"]
        },
        Tile::READ_TILE => {
          name: "Read Tile",
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
          question: "Fill in statement",
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
          question: "Add question",
          answers: ["Add Answer Option", "Add Answer Option"]
        },
        Tile::RSVP_TO_EVENT.parameterize("_") => {
          name: "RSVP To Event",
          question: "Will you be attending?",
          answers: ["Yes", "No", "Maybe"]
        }
      }
    }
  end

  def update_tile_types tile_types, tile
    old_tile_type(tile) unless tile.question_type
    type = tile.question_type
    subtype = tile.question_subtype
    question = tile.question
    answers = tile.multiple_choice_answers
    correct = tile.correct_answer_index
    tile_types[type][subtype][:question] = question
    tile_types[type][subtype][:answers] = answers
    tile_types[type][subtype][:correct] = correct
    tile_types
  end

  def old_tile_type tile
    tile.question_type =  tile.is_survey? ? Tile::SURVEY : Tile::QUIZ
    tile.question_subtype = Tile::MULTIPLE_CHOICE
  end

  def single_tile_for_sort_js(tile)
    escape_javascript(
      render(
        partial: 'client_admin/tiles/manage_tiles/single_tile',
        locals: {presenter: SingleTilePresenter.new(tile, :html, @is_client_admin_action, browser.ie?)}
      )
    )
  end

  def tile_image_present(image_url)
    !image_url.nil? && !(image_url.include? User::MISSING_AVATAR_PATH)
  end

  def destroy_tile_message_params
    message = "Are you sure you want to delete this tile? Deleting a tile is irrevocable and you'll loose all data associated with it."
    if browser.ie?
      message
    else
      {
        body: message,
      }
    end
  end

  def draftSectionClass
    if !policy(:board).tile_suggestion_enabled?
      "suggestion_box_gated draft_selected"
    elsif params[:show_suggestion_box].present?
      "suggestion_box_selected"
    else
      'draft_selected'
    end
  end

  def display_show_more_draft_tiles
    count = if params[:show_suggestion_box].present?
      current_user.demo.suggested_tiles.count
    else
      current_user.demo.draft_tiles.count
    end
    (count > 6) ? 'display' : 'none'
  end

  def display_show_more_archive_tiles
    (current_user.demo.archive_tiles.count > 4) ? 'display' : 'none'
  end

  def suggestion_box_intro_params(show)
    if show
      {intro: "Give the people ability to create Tiles and submit them for your review."}
    else
      {}
    end
  end

  def tile_thumbnail_menu(presenter)
    render(partial: 'client_admin/tiles/manage_tiles/tile_thumbnail_menu', locals: {presenter: presenter})
  end
end
