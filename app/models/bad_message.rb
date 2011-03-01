class BadMessage < ActiveRecord::Base
  belongs_to :user

  def self.most_recent_first
    self.order('received_at DESC')
  end
end
