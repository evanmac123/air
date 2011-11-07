class CreateTimedBonus < ActiveRecord::Migration
  def self.up
    create_table :timed_bonus do |t|
      t.datetime :expires_at, :null => false
      t.boolean :fulfilled, :null => false, :default => false
      t.integer :points, :null => false
      t.string :sms_text, :null => false, :default => ''

      t.belongs_to :user
      t.belongs_to :demo
      t.timestamps
    end
  end

  def self.down
    drop_table :timed_bonus
  end
end
