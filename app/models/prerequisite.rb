class Prerequisite < ActiveRecord::Base
  belongs_to :tile
  belongs_to :prerequisite_tile, :class_name => "Tile"
end
