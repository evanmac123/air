# frozen_string_literal: true

class PopulationSegment < ActiveRecord::Base
  belongs_to :demo
  has_many :campaigns

  def users
    demo.users_in_segment(id)
  end

  def user_count
    users.count
  end
end
