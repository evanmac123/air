class CreateSuggestedTasks < ActiveRecord::Migration
  def self.up
    create_table :suggested_tasks do |t|
      t.string :name, :null => false, :default => ''
      t.string :short_description
      t.string :long_description

      t.belongs_to :demo

      t.timestamps
    end
  end

  def self.down
    drop_table :suggested_tasks
  end
end
