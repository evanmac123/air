# frozen_string_literal: true

class ExploreDigestPresenter
  include EmailHelper
  include ClientAdmin::TilesHelper
  include Rails.application.routes.url_helpers

  EXPLORE_EMAIL = "explore_digest"
  CURRENT_EMAIL_VERSION = "1/1/17"
  FROM_EMAIL = "Airbo Explore <airboexplore@ourairbo.com>"

  def initialize(explore_token)
    @explore_token = explore_token
  end

  def from_email
    FROM_EMAIL
  end

  def email_type
    EXPLORE_EMAIL
  end

  def general_site_url(requested_tile_id: nil)
    explore_url(
      explore_token: @explore_token,
      email_type: email_type,
      email_version: CURRENT_EMAIL_VERSION,
      requested_tile_id: requested_tile_id
    )
  end
end
