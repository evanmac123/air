class AddSponsorToDemo < ActiveRecord::Migration
  def self.up
    add_column :demos, :sponsor, :string
  end

  def self.down
    remove_columns :demos, :sponsor
  end
end
