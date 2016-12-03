class CreateExploreDigests < ActiveRecord::Migration
  def change
    create_table :explore_digests do |t|
      t.boolean :approved, default: false

      t.timestamps
    end
  end
end
