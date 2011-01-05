class Act < ActiveRecord::Base
  belongs_to :player

  def self.recent
    order('created_at desc')
  end
end
