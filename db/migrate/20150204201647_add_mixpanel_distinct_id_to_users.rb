class AddMixpanelDistinctIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mixpanel_distinct_id, :string
  end
end
