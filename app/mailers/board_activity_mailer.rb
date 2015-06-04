class BoardActivityMailer < BaseTilesDigestMailer

  ACTIVITY_DIGEST_HEADING = "Your Weekly Airbo Activity Report".freeze

  layout "mailer"
  default reply_to: 'support@airbo.com'
		
	def notify(demo_id, user_id, tile_ids, beg_date, end_date)
		@user  = User.find user_id # XTR
		return nil unless @user.email.present? 

		@beg_date = beg_date
		@end_date = end_date
		@demo = Demo.find demo_id
    @tile_ids = tile_ids

		@presenter = TilesDigestMailActivityPresenter.new(@user, @demo, beg_date, end_date )

		@tiles = TileWeeklyActivityDecorator.decorate_collection(
			tiles_by_position,  
			context: { demo: @demo, user: @user, follow_up_email: @follow_up_email, email_type:  @presenter.email_type }
		)     
   
		ping_on_digest_email @presenter.email_type, @user
		mail to: @user.email_with_name, from: @demo.reply_email_address, subject: ACTIVITY_DIGEST_HEADING
  end


end
