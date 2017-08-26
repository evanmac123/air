class CreateBoardHealthReports < ActiveRecord::Migration
  def change
    create_table :board_health_reports do |t|
      t.references :demo
      t.integer :tiles_copied_count
      t.integer :user_count
      t.decimal :activated_user_percent
      t.integer :tiles_posted_count
      t.decimal :tile_completion_average
      t.decimal :tile_completion_min
      t.decimal :tile_completion_max
      t.decimal :tile_view_average
      t.decimal :tile_view_max
      t.decimal :tile_view_min
      t.decimal :latest_tile_completion_rate
      t.decimal :latest_tile_view_rate
      t.integer :days_since_tile_posted
      t.date :from_date
      t.date :to_date
      t.integer :period_cd, default: 0
      t.integer :health_score

      t.timestamps
    end
    add_index :board_health_reports, :demo_id
  end
end
