class AddExploreTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :explore_token, :string
    add_index  :users, :explore_token
  end
end
