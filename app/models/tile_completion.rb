require 'ostruct'
class TileCompletion < ActiveRecord::Base
  serialize :custom_form, Hash
  belongs_to :user, polymorphic: true
  belongs_to :tile, counter_cache: true

  scope :for_period, ->(b,e){where(:created_at => b..e)}

  validates_uniqueness_of :tile_id, :scope => [:user_id, :user_type]

  # convenience method to convert the data in the serialzed hash to more
  # accessible object

  def custom_data
    @custom_form = OpenStruct.new(custom_form)
  end

  def self.user_completed_any_tiles?(user_id, tile_ids)
    where(user_id: user_id, tile_id: tile_ids).count > 0
  end
end
