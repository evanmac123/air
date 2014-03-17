class CreateImageContainers < ActiveRecord::Migration
  def change
    create_table :image_containers do |t|
      t.attachment :image

      t.timestamps
    end
  end
end
