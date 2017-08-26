class AddHealthScoreToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :current_health_score, :integer
  end
end
