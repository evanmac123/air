class BoardActivityMailer < ActionMailer::Base

  helper :email
  helper 'client_admin/tiles'
  helper ApplicationHelper

  has_delay_mail

  include EmailHelper
  include ClientAdmin::TilesHelper # and ditto

  layout nil#'mailer'

  default reply_to: 'support@airbo.com'
		
  def notify(board, user, tiles)
    @demo =board
		@user  = user 
		@tiles = tiles #TileBoardDigestDecorator.decorate_collection tiles 
    return nil unless @user.email.present? 
    ping_on_digest_email @user
		mail to: @user.email_with_name, from: @demo.reply_email_address, subject: "Your Weekly Activity" 
  end

  def ping_on_digest_email  user
    TrackEvent.ping( "Email Sent", {email_type: "Activity - v. 6/15/14"}, user )
  end

end
