class AddSmsSlugToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :sms_slug, :string, :default => "", :null => false
    add_index :users, :sms_slug
  end

  def self.down
    remove_index :users, :column => :sms_slug
    remove_column :users, :sms_slug
  end
end
