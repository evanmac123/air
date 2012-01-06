class AddedPrimaryTagToRule < ActiveRecord::Migration
  def self.up
    add_column :rules, :primary_tag_id, :integer
  end

  def self.down
    remove_columns :rules, :primary_tag_id
  end
end
