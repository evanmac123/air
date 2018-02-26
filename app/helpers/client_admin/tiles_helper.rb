# frozen_string_literal: true

module ClientAdmin::TilesHelper
  include EmailHelper

  def digest_email_site_link(user, demo_id, email_type = "")
    email_link_hash = {
      user_id: user.id,
      demo_id: demo_id,
      tile_token: EmailLink.generate_token(user),
      email_type: email_type
    }

    if user.claimed?
      acts_url(email_link_hash)
    else
      invitation_url(user.invitation_code.to_s, email_link_hash)
    end
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

  def tile_thumbnail_menu(presenter)
    render(partial: "client_admin/tiles/manage_tiles/tile_thumbnail_menu", locals: { presenter: presenter })
  end

  def tile_container_data(presenter)
    {
      "tile-container-id" => presenter.tile_id,
      status: presenter.status,
      media_source: presenter.media_source,
      has_completions: presenter.tile_completions_count > 0,
      assembly_required: presenter.assembly_required?,
      config: presenter.question_config.to_json,
      headline: presenter.headline,
      has_attachments: presenter.has_attachments,
      attachment_count: presenter.attachment_count
    }
  end
end
