class Cheer < ActiveRecord::Base
  attr_accessible :body
  validates :body, presence: true

  def self.today?
    last.created_at.today?
  end

  def self.sample
    pluck(:body).sample
  end
end
