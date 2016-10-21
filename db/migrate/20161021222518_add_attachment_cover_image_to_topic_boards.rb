class AddAttachmentCoverImageToTopicBoards < ActiveRecord::Migration
  def self.up
    change_table :topic_boards do |t|
      t.has_attached_file :cover_image
    end
  end

  def self.down
    drop_attached_file :topic_boards, :cover_image
  end
end
