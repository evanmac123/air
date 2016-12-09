class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string :name
      t.attachment :image

      t.timestamps
    end
  end
end
