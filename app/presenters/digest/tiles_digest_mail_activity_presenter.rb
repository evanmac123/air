class TilesDigestMailActivityPresenter < TilesDigestMailBasePresenter
  ACTIVITY_EMAIL = "weekly_activity_v".freeze
  ACTIVITY_DIGEST_HEADING = "Weekly Activity Report".freeze

  include ClientAdmin::TilesHelper
  include Rails.application.routes.url_helpers

	def initialize(user, demo, beg_date, end_date)

		@beg_date = beg_date
		@end_date = end_date
		super("Here is your board's activity from #{pretty_date_range}.")
    @user = user
    @demo = demo
  end

  def from_email
    if @custom_from.present?
      @custom_from
    else
      @demo.reply_email_address
    end
  end

  def email_heading
    @custom_headline.present? ? @custom_headline : standard_email_heading
  end


	def pretty_date_range
		"#{@beg_date.strftime('%A, %B %d')} to #{@end_date.strftime('%A, %B %d')}"
	end

  def standard_email_heading
    ACTIVITY_DIGEST_HEADING
  end

  def digest_email_heading
    ACTIVITY_DIGEST_HEADING
  end

  def title
    join_demo_copy_or_digest_email_heading(@is_new_invite)
  end

  def email_type
    ACTIVITY_EMAIL
  end

  def general_site_url
		client_admin_tiles_url
  end
end
