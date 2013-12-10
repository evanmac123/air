class AssociateUserAndGuestUser < ActiveRecord::Migration
  def change
    add_column :users, :original_guest_user_id, :integer, index: true
    add_column :guest_users, :converted_user_id, :integer, index: true
  end
end
