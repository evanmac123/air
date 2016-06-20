class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.integer :num_employees
      t.string :sales_channel
      t.boolean :churned
      t.text :churn_reason

      t.timestamps
    end
  end
end
