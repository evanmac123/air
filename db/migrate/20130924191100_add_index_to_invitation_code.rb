class AddIndexToInvitationCode < ActiveRecord::Migration
  def up
    execute "commit" # this ends the transaction that this migration is wrapped in,
                     # since we can't create index concurrently within one. Yes, it's a
                     # hack.

    execute "CREATE INDEX CONCURRENTLY index_users_on_invitation_code ON users USING btree(invitation_code)"
  end

  def down
    remove_index :users, :invitation_code
  end
end
