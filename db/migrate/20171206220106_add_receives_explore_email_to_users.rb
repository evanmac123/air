class AddReceivesExploreEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :receives_explore_email, :boolean, default: true
  end
end
