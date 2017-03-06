class ExploreDigestPresenter < TilesDigestMailBasePresenter
  include Rails.application.routes.url_helpers
  include EmailHelper

  EXPLORE_TITLE = "Explore digest".freeze
  EXPLORE_EMAIL = "explore_digest".freeze

  attr_reader :email_heading

  def initialize(explore_token)
    @explore_token = explore_token
  end

  def from_email
    "Airbo Explore <airboexplore@ourairbo.com>"
  end

  def title
    EXPLORE_TITLE
  end

  def email_type
    EXPLORE_EMAIL
  end

  def general_site_url(requested_tile_id: nil)
    if Rails.env.development? or Rails.env.test?
      'http://localhost:3000' + explore_path(explore_token: @explore_token, email_type: email_type, requested_tile_id: requested_tile_id)
    else
      explore_url(explore_token: @explore_token, email_type: email_type, host: email_link_host, protocol: email_link_protocol, requested_tile_id: requested_tile_id)
    end
  end

  def works_on_mobile?
    false
  end
end
