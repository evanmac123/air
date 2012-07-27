class CreateClaimAttemptHistories < ActiveRecord::Migration
  def change
    create_table :claim_attempt_histories do |t|
      t.string :from, :null => false, :default => ''
      t.text :claim_information

      t.belongs_to :claim_state
      t.timestamps
    end

    add_index :claim_attempt_histories, :from
  end
end
