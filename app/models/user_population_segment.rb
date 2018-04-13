class UserPopulationSegment < ActiveRecord::Base
  belongs_to :user
  belongs_to :population_segment

  validates_associated :population_segment
  validates_associated :user

  scope :active, -> { where(active: true) }
end
