class AddLastUnmonitoredMailboxResponseAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_unmonitored_mailbox_response_at, :datetime
  end
end
