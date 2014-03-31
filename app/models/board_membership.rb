class BoardMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :demo
  belongs_to :location

  def self.current
    where(is_current: true)
  end
end
