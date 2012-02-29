class RenameInResponseTo2RequestSms < ActiveRecord::Migration
  def self.up
    rename_column :outgoing_sms, :in_response_to_id, :mate_id   
  end

  def self.down
    rename_column :outgoing_sms, :mate_id, :in_response_to_id   
  end
end
