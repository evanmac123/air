# frozen_string_literal: true

class PopulationSegment < ActiveRecord::Base
  belongs_to :demo
  has_many :campaigns
  has_many :user_population_segments, dependent: :destroy
  has_many :users, through: :user_population_segments
end
