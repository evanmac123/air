class CreateBonusThresholds < ActiveRecord::Migration
  def self.up
    create_table :bonus_thresholds do |t|
      t.integer :threshold, :null => false
      t.integer :max_points, :null => false
      t.belongs_to :demo
      t.timestamps
    end

    add_index :bonus_thresholds, :demo_id
  end

  def self.down
    drop_table :bonus_thresholds
  end
end
