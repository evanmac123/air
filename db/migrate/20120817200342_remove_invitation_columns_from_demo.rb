class RemoveInvitationColumnsFromDemo < ActiveRecord::Migration
  def up
    remove_column :demos, :invitation_bullet_1
    remove_column :demos, :invitation_bullet_2
    remove_column :demos, :invitation_bullet_3
    remove_column :demos, :invitation_blurb
    remove_column :demos, :invitation_blurb_with_referrer
    remove_column :demos, :invitation_screenshot_filename
    remove_column :demos, :invitation_logo_filename
    remove_column :demos, :invitation_subject
    remove_column :demos, :invitation_subject_with_referrer
   end

  def down
    add_column :demos, :invitation_bullet_1, :string, :default => ''
    add_column :demos, :invitation_bullet_2, :string, :default => ''
    add_column :demos, :invitation_bullet_3, :string, :default => ''
    add_column :demos, :invitation_blurb, :string, :default => ''
    add_column :demos, :invitation_blurb_with_referrer, :string, :default => ''
    add_column :demos, :invitation_screenshot_filename, :string, :default => ''
    add_column :demos, :invitation_logo_filename, :string, :default => ''
    add_column :demos, :invitation_subject, :string, :default => ''
    add_column :demos, :invitation_subject_with_referrer, :string, :default => ''
  end
end
