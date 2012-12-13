class Make20PointsTicketDefault < ActiveRecord::Migration
  def up
    change_column :demos, :ticket_threshold, :integer, :default => 20
  end

  def down
    change_column :demos, :ticket_threshold, :integer
  end
end
