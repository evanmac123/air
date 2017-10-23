class BoardActivityMailer < BaseTilesDigestMailer

  ACTIVITY_DIGEST_HEADING = "Your Weekly Airbo Activity Report".freeze

  default reply_to: 'support@airbo.com'

  def notify(demo_id, user_id, tile_ids, beg_date, end_date)
    @user  = User.find(user_id)

    @beg_date = beg_date
    @end_date = end_date
    @demo = Demo.find(demo_id)
    @tile_ids = tile_ids

    @presenter = TilesDigestMailActivityPresenter.new(@user, @demo, beg_date, end_date)

    @tiles = TileWeeklyActivityDecorator.decorate_collection(
    tiles_by_position, context: { demo: @demo, user: @user, follow_up_email: @follow_up_email, email_type:  @presenter.email_type })

    x_smtpapi_unique_args = @demo.data_for_mixpanel(user: @user).merge({
      subject: ACTIVITY_DIGEST_HEADING,
      email_type: @presenter.email_type
    })

    set_x_smtpapi_headers(category: @presenter.email_type, unique_args: x_smtpapi_unique_args)

    mail to: @user.email_with_name, from: @demo.reply_email_address, subject: ACTIVITY_DIGEST_HEADING
  end
end
