# frozen_string_literal: true

class RibbonTag < ActiveRecord::Base
  belongs_to :demo
  has_many :tiles

  validates_presence_of :name, allow_blank: false
  validates_presence_of :color, allow_blank: false

  def schedule_mixpanel_ping(event)
    data_hash = { topic_id: id, name: name, board_id: demo.id }
    TrackEvent.ping(event, data_hash)
  end
end
