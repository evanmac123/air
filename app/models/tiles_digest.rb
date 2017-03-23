class TilesDigest < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'

  def self.build_and_create(params)

  end
end
