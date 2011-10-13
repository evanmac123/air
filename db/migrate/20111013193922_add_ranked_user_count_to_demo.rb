class AddRankedUserCountToDemo < ActiveRecord::Migration
  def self.up
    add_column :demos, :ranked_user_count, :integer
    execute "UPDATE demos SET ranked_user_count=(SELECT count(*) FROM users WHERE users.demo_id = demos.id AND users.phone_number IS NOT NULL AND users.phone_number != '')"
    change_column :demos, :ranked_user_count, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :demos, :ranked_user_count
  end
end
