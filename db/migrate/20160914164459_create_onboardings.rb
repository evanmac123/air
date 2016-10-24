class CreateOnboardings < ActiveRecord::Migration
  def change
    create_table :onboardings do |t|
      t.references :organization

      t.timestamps
    end
    add_index :onboardings, :organization_id
  end
end
