class CreateClaimStateMachines < ActiveRecord::Migration
  def change
    create_table :claim_state_machines do |t|
      t.text :states
      t.belongs_to :demo
      t.integer :start_state_id, :default => 1
      t.timestamps
    end
  end
end
