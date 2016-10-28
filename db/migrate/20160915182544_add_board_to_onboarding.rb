class AddBoardToOnboarding < ActiveRecord::Migration
  def change
    add_column :onboardings, :demo_id, :integer
    add_index :onboardings, :demo_id
  end
end
