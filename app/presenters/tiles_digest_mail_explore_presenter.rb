class TilesDigestMailExplorePresenter < TilesDigestMailBasePresenter
  EXPLORE_TITLE = "Explore digest".freeze

  def initialize(custom_from, custom_message, email_heading)
    super(custom_message)
    @custom_from = custom_from
    @email_heading = email_heading
  end

  def from_email
    if @custom_from.present?
      @custom_from
    else
      "Airbo <play@ourairbo.com>"
    end
  end

  def title
    EXPLORE_TITLE
  end

  attr_reader :email_heading
end
