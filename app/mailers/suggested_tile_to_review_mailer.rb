class SuggestedTileToReviewMailer < ActionMailer::Base
  has_delay_mail
  layout "mailer"
  helper :email

  def notify_all tile_sender_id, _demo_id
    user  = User.find tile_sender_id
    client_admin_ids = User.joins{board_memberships} \
                        .where do
                          (board_memberships.is_client_admin == true) &
                          (board_memberships.demo_id == _demo_id)
                        end \
                        .pluck(:id)
    
    client_admin_ids.each do |client_admin_id|
      SuggestedTileToReviewMailer.delay.notify_one client_admin_id, _demo_id, 
                                                   user.name, user.email
    end
  end

  def notify_one client_admin_id, demo_id, tile_sender_name, tile_sender_email
    @user  = User.find client_admin_id
    return nil unless @user.email.present?

    @demo = Demo.find  demo_id
    @name, @email = tile_sender_name, tile_sender_email
    @link = client_admin_tiles_url(show_suggestion_box: true, suggested_tile_intro: true)

    mail  from:     "suggestion_box@airbo.com",
          to:       @user.email,
          subject:  "New Tile Suggested To Review"
  end
end
