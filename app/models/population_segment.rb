# frozen_string_literal: true

class PopulationSegment < ActiveRecord::Base
  belongs_to :demo
  has_many :campaigns, dependent: :nullify
  has_many :user_population_segments, dependent: :destroy
  has_many :users, through: :user_population_segments

  validates :name, presence: true
  validates_uniqueness_of :name, case_sensitive: false, scope: :demo_id
  before_validation :strip_whitespace

  def user_count
    users.count
  end

  private

    def strip_whitespace
      self.name = self.name.try(:strip)
    end
end
