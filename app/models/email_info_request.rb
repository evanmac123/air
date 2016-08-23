class EmailInfoRequest < ActiveRecord::Base
  def notify
    EmailInfoRequestNotifier.delay_mail(:info_requested, self)
  end

  def pretty_source
    source.gsub("_", " ").upcase
  end
end
