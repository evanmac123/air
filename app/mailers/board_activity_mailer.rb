# frozen_string_literal: true

class BoardActivityMailer < BaseTilesDigestMailer
  ACTIVITY_DIGEST_HEADING = "Your Weekly Airbo Activity Report".freeze

  default reply_to: "support@airbo.com"

  def notify(demo_id, user, tile_ids, beg_date, end_date)
    @user = user

    @beg_date = beg_date
    @end_date = end_date
    @demo = Demo.find(demo_id)
    @tile_ids = tile_ids

    @presenter = ActivityDigestPresenter.new(@user, @demo, beg_date, end_date)

    @tiles = tiles_by_position

    x_smtpapi_unique_args = @demo.data_for_mixpanel(user: @user).merge(
      subject: ACTIVITY_DIGEST_HEADING,
      email_type: @presenter.email_type
    )

    set_x_smtpapi_headers(category: @presenter.email_type, unique_args: x_smtpapi_unique_args)

    mail to: @user.email_with_name, from: @demo.reply_email_address, subject: ACTIVITY_DIGEST_HEADING
  end
end
