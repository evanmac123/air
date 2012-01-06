class CreateLabels < ActiveRecord::Migration
  def self.up
    create_table :labels do |t|
      t.integer :rule_id
      t.integer :tag_id

      t.timestamps
    end
  end

  def self.down
    drop_table :labels
  end
end
