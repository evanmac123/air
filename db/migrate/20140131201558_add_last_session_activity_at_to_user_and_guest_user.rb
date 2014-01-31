class AddLastSessionActivityAtToUserAndGuestUser < ActiveRecord::Migration
  def change
    add_column :users, :last_session_activity_at, :timestamp
    add_column :guest_users, :last_session_activity_at, :timestamp
  end
end
