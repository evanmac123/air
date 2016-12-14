class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.references :demo
      t.string :description
      t.attachment :cover_image
      t.string :name
      t.boolean :active, default: false

      t.timestamps
    end
    add_index :campaigns, :demo_id
  end
end
