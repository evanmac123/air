class CustomDemoFieldsForInvitationEmail < ActiveRecord::Migration
  def up
    add_column :demos, :invitation_blurb,    :text,   :null => false, :default => ''
    add_column :demos, :invitation_bullet_1, :string, :null => false, :default => ''
    add_column :demos, :invitation_bullet_2, :string, :null => false, :default => ''
    add_column :demos, :invitation_bullet_3, :string, :null => false, :default => ''
    add_column :demos, :invitation_logo_filename, :string, :null => false, :default => ''
  end

  def down
    remove_columns :demos, :invitation_blurb, :invitation_bullet_1, :invitation_bullet_2, :invitation_bullet_3, :invitation_logo_filename




  end
end
