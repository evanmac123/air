class AddFreeTrialStartedAtToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :free_trial_started_at, :date
  end
end
