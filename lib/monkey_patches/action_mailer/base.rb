class ActionMailer::Base
  DEFAULT_PLAY_ADDRESS = Rails.env.production? ? "play@playhengage.com" : "play-#{Rails.env}@playhengage.com"

  include Reply
  
  module ChannelSpecificTranslations
    def channel_specific_translations
      {
         "reply here" => (@user && "If you'd like to play by e-mail instead of texting or going to the website, you can always send your commands to #{@user.reply_email_address(false)}.")
      }
    end
  end

  include ChannelSpecificTranslations
  extend ChannelSpecificTranslations
end
