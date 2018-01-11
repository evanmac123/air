class ReviewSuggestedTileBulkMailJob < ActiveJob::Base
  queue_as :default

  def perform(tile:)
    user = tile.creator
    demo = tile.demo

    client_admin_ids = demo.board_memberships.where(is_client_admin: true).pluck(:user_id)

    client_admin_ids.each do |client_admin_id|
      SuggestedTileReviewMailer.notify_one(client_admin_id, demo.id, user.name, user.email).deliver_now
    end
  end
end
