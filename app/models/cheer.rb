class Cheer < ActiveRecord::Base
  validates :body, presence: true

  def self.today?
    last.created_at.today? if last
  end

  def self.sample
    pluck(:body).sample
  end
end
