class AddEmailToDemos < ActiveRecord::Migration
  def self.up
    add_column :demos, :email, :string
  end

  def self.down
    remove_column :demos, :email
  end
end
