class AddLastActedAtToGuestUsers < ActiveRecord::Migration
  def change
    add_column :guest_users, :last_acted_at, :datetime
  end
end
