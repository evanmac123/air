class RemoveTicketSpreadAttributesFromDemos < ActiveRecord::Migration
  def up
    remove_column :demos, :minimum_ticket_award
    remove_column :demos, :maximum_ticket_award
  end

  def down
    add_column :demos, :maximum_ticket_award, :integer
    add_column :demos, :minimum_ticket_award, :integer
  end
end
