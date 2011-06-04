class CreateBonusThresholds < ActiveRecord::Migration
  def self.up
    create_table :bonus_thresholds do |t|
      t.integer :min_points, :null => false
      t.integer :max_points, :null => false
      t.integer :award, :null => false
      t.belongs_to :demo
      t.timestamps
    end

    add_index :bonus_thresholds, :demo_id
    add_index :bonus_thresholds, :min_points
    add_index :bonus_thresholds, :max_points
  end

  def self.down
    drop_table :bonus_thresholds
  end
end
