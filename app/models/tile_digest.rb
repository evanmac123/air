# frozen_string_literal: true

class TileDigest < ActiveRecord::Base
  has_many :tiles
  belongs_to :demo
end
