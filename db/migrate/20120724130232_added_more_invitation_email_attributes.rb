class AddedMoreInvitationEmailAttributes < ActiveRecord::Migration
  def up
    rename_column :demos, :invitation_bullet_1, :invitation_bullet_1a
    rename_column :demos, :invitation_bullet_2, :invitation_bullet_2a
    rename_column :demos, :invitation_bullet_3, :invitation_bullet_3a
    add_column :demos, :invitation_bullet_1b, :string, :null => false, :default => ''
    add_column :demos, :invitation_bullet_2b, :string, :null => false, :default => ''
    add_column :demos, :invitation_bullet_3b, :string, :null => false, :default => ''
  end

  def down
    rename_column :demos, :invitation_bullet_1a, :invitation_bullet_1
    rename_column :demos, :invitation_bullet_2a, :invitation_bullet_2
    rename_column :demos, :invitation_bullet_3a, :invitation_bullet_3
    remove_columns :demos, :invitation_bullet_1b, :invitation_bullet_2b, :invitation_bullet_3b
  end
end
