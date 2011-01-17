class AddSlugToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :slug, :string, :default => "", :null => false
  end

  def self.down
    remove_column :users, :slug
  end
end
