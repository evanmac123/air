class AddInviteeTypeToPeerInvitation < ActiveRecord::Migration
  def change
  	add_column :peer_invitations, :invitee_type, :string, default: "User"
  end
end
