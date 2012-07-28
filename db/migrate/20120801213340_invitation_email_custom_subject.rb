class InvitationEmailCustomSubject < ActiveRecord::Migration
  def up
    add_column :demos, :invitation_subject,               :text, :null => false, :default => ''
    add_column :demos, :invitation_subject_with_referrer, :text, :null => false, :default => ''
  end

  def down
    remove_columns :demos, :invitation_subject, :invitation_subject_with_referrer
  end
end
