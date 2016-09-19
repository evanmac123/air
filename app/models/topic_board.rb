class TopicBoard < ActiveRecord::Base

  belongs_to :board, class_name: Demo, foreign_key: :demo_id
  belongs_to :topic
  scope :library_board_set, ->{where is_library: true}
  scope :reference_board_set, ->{where is_reference: true}

  validates :topic, :board, presence: true
  validates :is_reference, uniqueness:  {scope: :topic_id}

  def topic_name
    topic.name
  end

  def board_name
    board.name
  end

  def tiles
    board.active_tiles
  end
end
