class CreateActs < ActiveRecord::Migration
  def self.up
    create_table :acts do |t|
      t.integer :player_id
      t.string  :text

      t.timestamps
    end

    add_index :acts, :player_id
  end

  def self.down
    drop_table :acts
  end
end
