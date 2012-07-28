class InvitationEmailBlurbWithReferrer < ActiveRecord::Migration
  def up
    add_column :demos, :invitation_blurb_with_referrer, :text, :null => false, :default => ''
  end

  def down
    remove_columns :demos, :invitation_blurb_with_referrer
  end
end
