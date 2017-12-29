class GameCreationRequest < ActiveRecord::Base
  serialize :interests

  def schedule_notification
    GameCreationRequestMailer.notify_ks(self).deliver_later
  end
end
