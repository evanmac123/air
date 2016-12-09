class DropOutgoingEmails < ActiveRecord::Migration
  def up
    drop_table :outgoing_emails
  end

  def down
  end
end
