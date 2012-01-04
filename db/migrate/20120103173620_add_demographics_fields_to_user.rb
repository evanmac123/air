class AddDemographicsFieldsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :date_of_birth, :date
    add_column :users, :height, :integer
    add_column :users, :weight, :integer
    add_column :users, :gender, :string
  end

  def self.down
    remove_column :users, :gender
    remove_column :users, :weight
    remove_column :users, :height
    remove_column :users, :date_of_birth
  end
end
