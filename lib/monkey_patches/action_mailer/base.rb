class ActionMailer::Base
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
