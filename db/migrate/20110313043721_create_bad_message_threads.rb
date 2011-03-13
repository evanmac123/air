class CreateBadMessageThreads < ActiveRecord::Migration
  def self.up
    create_table :bad_message_threads do |t|
      t.timestamps
    end

    add_column :bad_messages, :thread_id, :integer
  end

  def self.down
    remove_column :bad_messages, :thread_id

    drop_table :bad_message_threads
  end
end
