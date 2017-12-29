class EmailInfoRequest < ActiveRecord::Base
  def notify
    EmailInfoRequestNotifier.info_requested(self).deliver_later
  end

  def pretty_source
    source.gsub("_", " ").upcase
  end
end
