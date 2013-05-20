class Tag < ActiveRecord::Base
  validates :name, :uniqueness => true, :presence => true
  has_many :labels
  has_many :rules, :through => :labels
  has_many :rules_as_primary_tag, :class_name => 'Rule', :foreign_key => :primary_tag_id

  def self.with_daily_limit
    where("daily_limit IS NOT NULL")
  end
end
