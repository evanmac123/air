class AddDelayedJobIdToRaffle < ActiveRecord::Migration
  def change
  	add_column :raffles, :delayed_job_id, :integer
  end
end
