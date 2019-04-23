# frozen_string_literal: true

class TilesDigestBucket < ActiveRecord::Base
  has_many :tiles
  belongs_to :demo
  has_one :tiles_digest
end
