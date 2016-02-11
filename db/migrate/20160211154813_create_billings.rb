class CreateBillings < ActiveRecord::Migration
  def change
    create_table :billings do |t|
      t.decimal :amount
      t.date :posted

      t.timestamps
    end
  end
end
