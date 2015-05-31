class BoardActivityMailer < ActionMailer::Base

  helper :email
  helper 'client_admin/tiles'
  helper ApplicationHelper

  has_delay_mail

  include EmailHelper
  include ClientAdmin::TilesHelper # and ditto

  layout nil#'mailer'

  default reply_to: 'support@airbo.com'

  def active_boards
    @collector = ActiveBoardCollector.new

    @collector.boards.each do |active_board|
      notify_admin(active_board.demo.id, active_board.user.id, active_board.iles.map(&:id))
    end
  end

  def notify_admin(demo_id, user_id, tile_ids)
    @demo = Demo.find demo_id
    @user  = User.find user_id
    return nil unless @user.email.present? 

    @presenter = TilesDigestMailDigestPresenter.new(
      @user, @demo, custom_from, 
      custom_headline, custom_message, is_new_invite)

    email_type = @presenter.email_type
    ping_on_digest_email email_type, @user

    @tiles = TileBoardDigestDecorator.decorate_collection Tile.where(
      id: tile_ids).ordered_by_position,
      context: {
        demo: @demo,
        user: @user,
        follow_up_email: @follow_up_email,
        email_type: email_type,
      }

      mail to: @user.email_with_name, from: @presenter.from_email, subject: subject
  end

  def ping_on_digest_email email_type, user
    TrackEvent.ping( "Email Sent", {email_type: ping_message[email_type]}, user )
  end

  def ping_message
    {
      "digest_new_v" => "Digest - v. 6/15/14",
      "follow_new_v" => "Follow-up - v. 6/15/14",
      "explore_v_1"  => "Explore - v. 8/25/14"
    }
  end
end
