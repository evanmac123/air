class AddedUnsubscribeTable < ActiveRecord::Migration
  def up
    create_table :unsubscribes do |t|
      t.integer :user_id, :null => false
      t.text :reason, :default => "", :null => false
      t.timestamps
    end
  end

  def down
    drop_table :unsubscribes
  end
end
