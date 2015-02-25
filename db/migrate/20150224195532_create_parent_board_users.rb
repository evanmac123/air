class CreateParentBoardUsers < ActiveRecord::Migration
  def change
    create_table :parent_board_users do |t|
      t.integer :points, default: 0
      t.integer :tickets, default: 0
      t.integer :ticket_threshold_base, default: 0
      t.integer :demo_id
      t.integer :user_id
      t.datetime :last_acted_at
      t.datetime :last_session_activity_at

      t.timestamps
    end
  end
end
