class AddInvitationCodeToPlayers < ActiveRecord::Migration
  def self.up
    add_column :players, :invitation_code, :string, :default => "", :null => false
  end

  def self.down
    remove_column :players, :invitation_code
  end
end
