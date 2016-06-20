class CreateSupports < ActiveRecord::Migration
  def change
    create_table :supports do |t|
      t.text :body, default: ""

      t.timestamps
    end
  end
end
