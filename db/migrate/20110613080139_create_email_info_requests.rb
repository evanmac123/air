class CreateEmailInfoRequests < ActiveRecord::Migration
  def self.up
    create_table :email_info_requests do |t|
      t.string :email
      t.timestamps
    end
  end

  def self.down
    drop_table :email_info_requests
  end
end
