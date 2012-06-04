class AddedReasonableDefaults < ActiveRecord::Migration
  def self.up
    add_column :demos, :example_tooltip, :string
    add_column :demos, :example_tutorial, :string
  end

  def self.down
    remove_columns :demos, :example_tooltip, :example_tutorial
  end
end
