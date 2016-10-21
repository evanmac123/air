class TopicBoard < ActiveRecord::Base

  belongs_to :board, class_name: Demo, foreign_key: :demo_id
  belongs_to :topic
  scope :library_board_set, ->{ where is_library: true }
  scope :reference_board_set, ->{ where is_reference: true }
  scope :onboarding_board_set, ->{ where is_onboarding: true }
  has_attached_file :cover_image, styles: { medium: "300x200>", thumb: "100x100>" }, default_url: "/images/airbo_venice.png"

  validates_attachment_content_type :cover_image, content_type: /\Aimage\/.*\z/

  validates :cover_image, presence: true
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
      if reference_board_exists
        errors.add(:base, "There is already a reference board selected for the '#{topic_name}' topic")
      end
    end

    def reference_board_exists
      TopicBoard.where(topic_id: topic_id, is_reference: true).any? && is_reference && changed.grep("is_reference").any?
    end
end
