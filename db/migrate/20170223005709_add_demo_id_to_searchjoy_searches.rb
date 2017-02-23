class AddDemoIdToSearchjoySearches < ActiveRecord::Migration
  def change
    add_column :searchjoy_searches, :demo_id, :integer
    add_column :searchjoy_searches, :user_email, :string
  end
end
