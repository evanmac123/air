class CreateKeys < ActiveRecord::Migration
  def self.up
    create_table :keys do |t|
      t.string :name
      t.timestamps
    end

    add_index :keys, :name
  end

  def self.down
    drop_table :keys
  end
end
