class CreateTopicBoards < ActiveRecord::Migration
  def change
    create_table :topic_boards do |t|
      t.integer :demo_id
      t.integer :topic_id
      t.boolean :is_reference
      t.boolean :is_library

      t.timestamps
    end
  end
end
