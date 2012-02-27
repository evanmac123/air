class ActionMailer::Base
  DEFAULT_PLAY_ADDRESS = Rails.env.production? ? "play@playhengage.com" : "play-#{Rails.env}@playhengage.com"

  include Reply

  def self.channel_specific_translations
    {
      "reply here" => "reply to this email with your command. OR you should have received another email from us with instructions for how to log into the web site"
    }
  end
end
