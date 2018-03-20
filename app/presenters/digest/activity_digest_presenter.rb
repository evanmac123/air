# frozen_string_literal: true

class ActivityDigestPresenter
  include EmailHelper
  include ClientAdmin::TilesHelper
  include Rails.application.routes.url_helpers

  ACTIVITY_EMAIL = "client_admin_activity_report".freeze
  ACTIVITY_DIGEST_HEADING = "Weekly Activity Report".freeze
  EMAIL_VERSION = "v.2".freeze

  def initialize(user, demo, beg_date, end_date)
    @beg_date = beg_date
    @end_date = end_date
    @user = user
    @demo = demo
  end

  def color
    "#4fd4c0"
  end

  def header
    "Weekly Activity Report"
  end

  def heading
    "Hi #{@user.first_name}!"
  end

  def message
    "Here is a snapshot of #{@demo.name}'s Tile activity from the last week."
  end

  def tile_button_copy
    "View Your Reports"
  end

  def airbo_reports_branding_title
    "Airbo Reports"
  end

  def airbo_reports_cta_copy
    "Track who’s engaging with your Tiles using Airbo Reports."
  end

  def airbo_reports_cta_button_copy
    "View Your Reports"
  end

  def from_email
    @demo.reply_email_address
  end

  def pretty_date_range
    "#{@beg_date.strftime('%A, %B %e, %Y')} to #{@end_date.strftime('%A, %B %e, %Y')}"
  end

  def email_type
    ACTIVITY_EMAIL
  end

  def email_version
    EMAIL_VERSION
  end

  def general_site_url
    client_admin_reports_url(email_type: email_type, email_version: email_version)
  end
end
