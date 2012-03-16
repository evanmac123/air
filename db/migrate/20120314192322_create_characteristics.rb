class CreateCharacteristics < ActiveRecord::Migration
  def self.up
    create_table :characteristics do |t|
      t.string :name
      t.string :description
      t.text :allowed_values
      t.belongs_to :demo
      t.timestamps
    end
  end

  def self.down
    drop_table :characteristics
  end
end
