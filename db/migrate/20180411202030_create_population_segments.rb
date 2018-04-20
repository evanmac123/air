class CreatePopulationSegments < ActiveRecord::Migration
  def change
    create_table :population_segments do |t|
      t.string :name
      t.references :demo, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
