class CreatePeerInvitations < ActiveRecord::Migration
  def change
    create_table :peer_invitations do |t|
      t.integer :inviter_id
      t.integer :invitee_id
      t.belongs_to :demo
      t.timestamps
    end

    add_index :peer_invitations, :inviter_id
    add_index :peer_invitations, :invitee_id
    add_index :peer_invitations, :demo_id
    add_index :peer_invitations, :created_at
  end
end
