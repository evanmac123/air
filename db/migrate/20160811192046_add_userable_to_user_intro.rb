class AddUserableToUserIntro < ActiveRecord::Migration
  def change
    add_column :user_intros, :userable_id, :integer 
    add_column :user_intros, :userable_type, :string 
  end
end
