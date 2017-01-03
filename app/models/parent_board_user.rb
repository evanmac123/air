class ParentBoardUser < ActiveRecord::Base
  belongs_to :demo
  belongs_to :user
  has_many   :tile_completions, :as => :user, :dependent => :destroy
  has_many   :tile_viewings, :as => :user, :dependent => :destroy
  has_many   :completed_tiles, source: :tile, through: :tile_completions
  has_many   :acts, :as => :user, :dependent => :destroy
  has_one :user_intro, as: :userable,  :dependent => :destroy
end
