class CreateRules < ActiveRecord::Migration
  def self.up
    create_table :rules do |t|
      t.belongs_to :key
      t.string :value
      t.integer :points

      t.timestamps
    end

    add_index :rules, :key_id
  end

  def self.down
    drop_table :rules
  end
end
