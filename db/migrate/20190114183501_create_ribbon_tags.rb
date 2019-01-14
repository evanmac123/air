class CreateRibbonTags < ActiveRecord::Migration
  def change
    create_table :ribbon_tags do |t|
      t.references :demo, index: true, foreign_key: true
      t.string :color
      t.string :name

      t.timestamps null: false
    end
  end
end
