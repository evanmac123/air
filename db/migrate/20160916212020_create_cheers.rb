class CreateCheers < ActiveRecord::Migration
  def change
    create_table :cheers do |t|
      t.string :body

      t.timestamps
    end
  end
end
