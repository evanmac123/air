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

  # Workaround for the fact that DJ/YAML upgrades break delayed invocation
  # of class & module methods
  def self.has_delay_mail
    self.class_eval <<-END_DELAY_MAIL_CODE
def self.delay_mail(method, *args)
  Delayed::Job.enqueue self::Delayer.new(method, *args)
end

class Delayer
  def initialize(method_name, *args)
    @method_name = method_name
    @args = args
  end

  def perform
    self.class.parent.send(@method_name, *@args).deliver
  end
end
END_DELAY_MAIL_CODE
  end
end
