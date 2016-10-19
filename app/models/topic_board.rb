class TopicBoard < ActiveRecord::Base

  belongs_to :board, class_name: Demo, foreign_key: :demo_id
  belongs_to :topic
  scope :library_board_set, ->{where is_library: true}
  scope :reference_board_set, ->{where is_reference: true}
  scope :onboarding_board_set, ->{where is_onboarding: true}

  validates :topic, :board, presence: true
  validate :one_reference_board_per_topic

  def topic_name
    topic.name
  end

  def board_name
    board.name
  end

  def tiles
    board.active_tiles
  end

  private

  def one_reference_board_per_topic
    if TopicBoard.exists? ["topic_id = ? AND  demo_id != ?", topic_id, demo_id]
      errors.add(:base, "There is already a reference board selected for the '#{topic_name}' topic")
    end
  end

end
