class UserTileCopy < ActiveRecord::Base
  belongs_to :user
  belongs_to :tile, counter_cache: true
  
  after_create do
    Mailer.delay_mail(:notify_creator_for_social_interaction, tile, user, 'copied')
  end
end
