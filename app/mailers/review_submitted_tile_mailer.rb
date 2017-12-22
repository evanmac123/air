class ReviewSubmittedTileMailer < ApplicationMailer
  layout "mailer"
  helper :email

  def self.notify_all tile_sender_id, _demo_id
    user  = User.find(tile_sender_id)

    client_admin_ids = user.demo.board_memberships.where(is_client_admin: true).pluck(:id)

    client_admin_ids.each do |client_admin_id|
      ReviewSubmittedTileMailer.notify_one(client_admin_id, _demo_id, user.name, user.email).deliver_later
    end
  end

  def notify_one(client_admin_id, demo_id, tile_sender_name, tile_sender_email)
    @user  = User.find client_admin_id
    return nil unless @user.email.present?

    @demo = Demo.find  demo_id
    @name, @email = tile_sender_name, tile_sender_email
    @link = submitted_tile_notifications_url demo_id: demo_id

    mail  from:     @demo.email,
          to:       @user.email,
          subject:  "New Tile Submitted Needs Review"
  end
end
