class TilesDigestMailExplorePresenter < TilesDigestMailBasePresenter
  include Rails.application.routes.url_helpers
  include EmailHelper

  EXPLORE_TITLE = "Explore digest".freeze
  EXPLORE_EMAIL = "explore_v_1".freeze

  def initialize(custom_from, custom_message, email_heading, explore_token, subject=nil)
    super(custom_message)
    @custom_from = custom_from
    @email_heading = email_heading
    @explore_token = explore_token
    @subject = subject
  end

  def from_email
    if @custom_from.present?
      @custom_from
    else
      "Airbo Explore <airboexplore@ourairbo.com>"
    end
  end

  def title
    EXPLORE_TITLE
  end

  def email_type
    EXPLORE_EMAIL
  end

  def general_site_url
    if Rails.env.development? or Rails.env.test?
      'http://localhost:3000' + explore_path(explore_token: @explore_token, email_type: email_type)
    else
      explore_url(explore_token: @explore_token, email_type: email_type, host: email_link_host, protocol: email_link_protocol)
    end
  end

  def works_on_mobile?
    false
  end

  attr_reader :email_heading
end
