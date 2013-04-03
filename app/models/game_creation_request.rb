class GameCreationRequest < ActiveRecord::Base
  serialize :interests

  def schedule_notification
    GameCreationRequestMailer.delay_mail(:notify_ks, self)
  end
end
