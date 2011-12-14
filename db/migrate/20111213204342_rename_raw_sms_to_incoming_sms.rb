class RenameRawSmsToIncomingSms < ActiveRecord::Migration
  def self.up
    rename_table :raw_sms, :incoming_sms
  end

  def self.down
    rename_table :incoming_sms, :raw_sms
  end
end
