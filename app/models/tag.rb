class Tag < ActiveRecord::Base
  validates :name, :uniqueness => true, :presence => true
  has_many :labels
  has_many :rules, :through => :labels
  extend Sequenceable

  def self.with_daily_limit
    where("daily_limit IS NOT NULL")
  end
end
