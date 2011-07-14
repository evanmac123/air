class EmailInfoRequest < ActiveRecord::Base
  after_create :notify_vlad

  def notify_vlad
    EmailInfoRequestNotifier.info_requested(name, email).deliver!
  end

  handle_asynchronously :notify_vlad
end
