class RemoveUsesTicketsFromDemo < ActiveRecord::Migration
  def up
    remove_column :demos, :uses_tickets
  end

  def down
    add_column :demos, :uses_tickets, :boolean
  end
end
