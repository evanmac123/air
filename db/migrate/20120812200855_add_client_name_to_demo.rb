class AddClientNameToDemo < ActiveRecord::Migration
  def up
    add_column :demos, :client_name, :string
    execute("UPDATE demos SET client_name = ''")
    change_column :demos, :client_name, :string, :default => '', :null => false
  end
  
  def down
    remove_column :demos, :client_name
  end
end
