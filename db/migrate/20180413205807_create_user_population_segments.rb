class CreateUserPopulationSegments < ActiveRecord::Migration
  def change
    create_table :user_population_segments do |t|
      t.references :user, index: true, foreign_key: true
      t.references :population_segment, index: true, foreign_key: true
      t.boolean :active, default: true

      t.timestamps null: false
    end
  end
end
