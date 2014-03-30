class BoardMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :demo

  def self.current
    where(is_current: true)
  end
end
