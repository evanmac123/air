class AddUserIdToMoreInfoRequest < ActiveRecord::Migration
  def change
    add_column :more_info_requests, :user_id, :integer
  end
end
