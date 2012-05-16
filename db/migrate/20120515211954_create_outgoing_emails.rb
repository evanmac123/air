class CreateOutgoingEmails < ActiveRecord::Migration
  def self.up
    create_table :outgoing_emails do |t|
      t.string :subject
      t.string :from
      t.text   :to
      t.text   :raw
      t.timestamps
    end

    add_index :outgoing_emails, :subject
    add_index :outgoing_emails, :to
    add_index :outgoing_emails, :created_at
  end

  def self.down
    drop_table :outgoing_emails
  end
end
