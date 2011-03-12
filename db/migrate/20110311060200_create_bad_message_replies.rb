class CreateBadMessageReplies < ActiveRecord::Migration
  def self.up
    create_table :bad_message_replies do |t|
      t.string :body, :limit => 160

      t.belongs_to :bad_message
      t.belongs_to :sender

      t.timestamps
    end
  end

  def self.down
    drop_table :bad_message_replies
  end
end
