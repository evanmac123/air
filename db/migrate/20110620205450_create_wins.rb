class CreateWins < ActiveRecord::Migration
  def self.up
    create_table :wins do |t|
      t.belongs_to :demo
      t.belongs_to :user

      t.timestamps
    end

    add_index :wins, :demo_id
    add_index :wins, :user_id
  end

  def self.down
    drop_table :wins
  end
end
