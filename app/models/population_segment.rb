# frozen_string_literal: true

class PopulationSegment < ActiveRecord::Base
  belongs_to :demo
  has_many :campaigns

  def user_count
  end
end
