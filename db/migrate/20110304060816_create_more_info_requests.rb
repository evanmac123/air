class CreateMoreInfoRequests < ActiveRecord::Migration
  def self.up
    create_table :more_info_requests do |t|
      t.string :phone_number

      t.timestamps
    end
  end

  def self.down
    drop_table :more_info_requests
  end
end
