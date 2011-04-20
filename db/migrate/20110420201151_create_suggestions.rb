class CreateSuggestions < ActiveRecord::Migration
  def self.up
    create_table :suggestions do |t|
      t.string :value, :null => false, :default => ''
      t.belongs_to :user
      t.timestamps
    end
  end

  def self.down
    drop_table :suggestions
  end
end
