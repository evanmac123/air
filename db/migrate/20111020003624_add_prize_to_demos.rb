class AddPrizeToDemos < ActiveRecord::Migration
  def self.up
    add_column :demos, :prize, :string
    execute("UPDATE demos SET prize='' WHERE PRIZE IS NULL")
    change_column :demos, :prize, :string, :null => false, :default => ''
  end

  def self.down
    remove_column :demos, :prize
  end
end
