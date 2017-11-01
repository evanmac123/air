class AddJobIdToTilesDigestAutomators < ActiveRecord::Migration
  def change
    add_column :tiles_digest_automators, :job_id, :integer
  end
end
