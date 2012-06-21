class AddedOverflowEmail < ActiveRecord::Migration
  def up
    add_column :users, :overflow_email, :string, :default => '' 
  end

  def down
    remove_columns :users, :overflow_email
  end
end
