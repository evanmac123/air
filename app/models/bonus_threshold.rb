class BonusThreshold < ActiveRecord::Base
  belongs_to :demo

  validates_presence_of :threshold, :max_points, :demo_id

  def points_awarded
    rand(self.max_points) + 1
  end

  def self.crossed(old_points, new_points)
    where(['threshold BETWEEN ? and ?', old_points + 1, new_points])
  end

  def self.in_threshold_order
    order('threshold ASC')
  end
end
