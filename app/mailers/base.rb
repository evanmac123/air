class ActionMailer::Base
  DEFAULT_PLAY_ADDRESS = Rails.env.production? ? "play@playhengage.com" : "play-#{Rails.env}@playhengage.com"
end
