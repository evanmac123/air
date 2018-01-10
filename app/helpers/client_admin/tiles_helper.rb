module ClientAdmin::TilesHelper
  include EmailHelper

  def email_site_link(user, demo, is_preview = false, email_type = "")
    # TODO: This is some of the worst Airbo code I have seen.
    _demo_id = demo.kind_of?(Demo) ? demo.id : demo

    email_link_hash = is_preview ? { demo_id: _demo_id } : { protocol: email_link_protocol, host: email_link_host, demo_id: _demo_id, email_type: email_type }
    email_link_hash.merge!(user_id: user.id, tile_token: EmailLink.generate_token(user)) if user.claimed?

    coder = HTMLEntities.new
    email_link_hash.map { |k, v| coder.encode(v.to_s) }
    (is_preview || user.claimed?) ? acts_url(email_link_hash) : invitation_url(coder.encode(user.invitation_code.to_s), email_link_hash)
  end

  def tile_image_present(image_url)
    !image_url.nil? && !(image_url.include? Tile::MISSING_PREVIEW)
  end

  def destroy_tile_message_params
    message = "Deleting a tile cannot be undone.\n\nAre you sure you want to delete this tile?"
    if browser.ie?
      message
    else
      {
        body: message,
      }
    end
  end

  def draftSectionClass
    if params[:show_suggestion_box].present?
      "suggestion_box_selected"
    else
      "draft_selected"
    end
  end

  def display_show_more_draft_tiles
    count = if params[:show_suggestion_box].present?
      current_user.demo.suggested_tiles.count
    else
      current_user.demo.draft_tiles.count
    end
    (count > 6) ? "display" : "none"
  end

  def display_show_more_archive_tiles
    (current_user.demo.archive_tiles.count > 4) ? "display" : "none"
  end

  def suggestion_box_intro_params(show)
    if show
      { intro: "Give the people ability to create Tiles and submit them for your review." }
    else
      {}
    end
  end

  def hide_suggestion_box_sub_menu
    if params[:show_suggestion_box] != "true"
      "hidden"
    end
  end

  def draft_tab_class(section)
    if draft_tab_selected(section) || suggestion_box_tab_selected(section)
      "selected"
    end
  end

  def draft_tab_selected(section)
    section == "draft" && params[:show_suggestion_box] != "true"
  end

  def suggestion_box_tab_selected(section)
    section == "suggestion_box" && params[:show_suggestion_box] == "true"
  end

  def tile_thumbnail_menu(presenter)
    render(partial: "client_admin/tiles/manage_tiles/tile_thumbnail_menu", locals: { presenter: presenter })
  end
end
