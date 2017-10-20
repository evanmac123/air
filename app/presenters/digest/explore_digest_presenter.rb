class ExploreDigestPresenter < TilesDigestMailBasePresenter
  include Rails.application.routes.url_helpers
  include EmailHelper

  EXPLORE_TITLE = "Explore digest".freeze
  EXPLORE_EMAIL = "explore_digest".freeze
  CURRENT_EMAIL_VERSION = "1/1/17".freeze
  FROM_EMAIL = "Airbo Explore <airboexplore@ourairbo.com>".freeze

  attr_reader :email_heading

  def initialize(explore_token)
    @explore_token = explore_token
  end

  def from_email
    FROM_EMAIL
  end

  def title
    EXPLORE_TITLE
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

  def works_on_mobile?
    false
  end
end
