class CreateDemoRequests < ActiveRecord::Migration
  def change
    create_table :demo_requests do |t|
      t.string :email

      t.timestamps
    end
  end
end
