class SetContactPrefsDefaultToEmail < ActiveRecord::Migration
  def up
    change_column :users, :notification_method, :string, :null => false, :default => :email
  end

  def down
    change_column :users, :notification_method, :string, :null => false, :default => :both
  end
end
