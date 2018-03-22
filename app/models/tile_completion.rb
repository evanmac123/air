# frozen_string_literal: true

require "ostruct"
class TileCompletion < ActiveRecord::Base
  serialize :custom_form, Hash
  belongs_to :user, polymorphic: true
  belongs_to :tile, counter_cache: true

  scope :for_period, ->(b, e) { where(created_at: b..e) }

  validates_uniqueness_of :tile_id, scope: [:user_id, :user_type]

  def custom_data
    @custom_form = OpenStruct.new(custom_form)
  end
end
