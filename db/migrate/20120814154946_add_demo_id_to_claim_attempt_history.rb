class AddDemoIdToClaimAttemptHistory < ActiveRecord::Migration
  def change
    add_column :claim_attempt_histories, :demo_id, :integer
    add_index :claim_attempt_histories, :demo_id
  end
end
