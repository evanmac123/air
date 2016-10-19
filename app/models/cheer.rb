class Cheer < ActiveRecord::Base
  attr_accessible :body, :created_at
  validates :body, presence: true

  def self.today?
    last && last.created_at.today?
  end

  def self.sample
    pluck(:body).sample
  end
end
