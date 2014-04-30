class UserTileLike < ActiveRecord::Base
  belongs_to :user
  belongs_to :tile
  validates_uniqueness_of :tile_id, :scope => [:user_id]
  
  after_create do
    Mailer.delay(run_at: 1.second.from_now).notify_creator_for_social_interaction(tile, user, 'liked')
  end
end
