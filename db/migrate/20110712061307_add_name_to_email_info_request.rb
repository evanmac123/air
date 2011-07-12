class AddNameToEmailInfoRequest < ActiveRecord::Migration
  def self.up
    add_column :email_info_requests, :name, :string
  end

  def self.down
    remove_column :email_info_requests, :name
  end
end
