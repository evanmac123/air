class AllowLongEmailInfoRequests < ActiveRecord::Migration
  def self.up
    change_column :email_info_requests, :comment, :text, :default => ""
  end

  def self.down
    change_column :email_info_requests, :comment, :string, :default => ""
  end
end
