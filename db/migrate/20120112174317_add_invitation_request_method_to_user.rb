class AddInvitationRequestMethodToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :invitation_method, :string
    execute "UPDATE users SET invitation_method = ''"
    change_column :users, :invitation_method, :string, :default => '', :null => false
  end

  def self.down
    remove_column :users, :invitation_method
  end
end
