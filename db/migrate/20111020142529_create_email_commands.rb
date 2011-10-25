class CreateEmailCommands < ActiveRecord::Migration
  def self.up
    create_table :email_commands do |t|
      t.integer :user_id
      t.string :status
      t.string :email_to
      t.string :email_from
      t.string :email_subject
      t.string :email_plain
      t.string :clean_command_string
      t.string :response
      t.datetime :response_sent

      t.timestamps
    end
  end

  def self.down
    drop_table :email_commands
  end
end
