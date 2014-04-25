class RemoveUnusedTables < ActiveRecord::Migration
  def up
    drop_table :bad_message_threads
    drop_table :claim_states
  end

  def down
    create_table :claim_states do |t|
    end

    create_table :bad_message_threads do |t|
      t.datetime  "created_at",              :null => false
      t.timestamp "updated_at", :limit => 3, :null => false
    end
  end
end
