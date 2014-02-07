class AddShowInviteUsersModalToUsers < ActiveRecord::Migration
  def change
    add_column :users, :show_invite_users_modal, :boolean, default: true
  end
end
