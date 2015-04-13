class UserTileLike < ActiveRecord::Base
  belongs_to :user
  belongs_to :tile, counter_cache: true
  validates_uniqueness_of :tile_id, :scope => [:user_id]
  
  after_create do
    Mailer.delay_mail(:notify_creator_for_social_interaction, tile, user, 'voted up')
  end
end
