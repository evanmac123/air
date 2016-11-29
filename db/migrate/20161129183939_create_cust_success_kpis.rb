class CreateCustSuccessKpis < ActiveRecord::Migration
  def change
    create_table :cust_success_kpis do |t|

      t.integer :paid_net_promoter_score
      t.integer :paid_net_promoter_score_response_count
      t.integer :total_paid_orgs
      t.integer :unique_org_with_activity_sessions
      t.integer :total_paid_client_admins
      t.integer :unique_client_admin_with_activity_sessions
      t.integer :total_paid_client_admin_activity_sessions
      t.integer :total_paid_client_admins
      t.integer :unique_orgs_that_copied_tiles
      t.integer :total_tiles_copied
      t.integer :orgs_that_posted_tiles
      t.integer :total_tiles_posted

      t.float :activity_sessions_per_client_admin
      t.float :average_tiles_copied_per_org_that_copied
      t.float :average_tiles_posted_per_organization_that_posted
      t.float :average_tile_creation_speed
      t.float :percent_engaged_organizations
      t.float :percent_engaged_client_admin
      t.float :percent_orgs_that_copied_tiles
      t.float :percent_of_orgs_that_posted_tiles
      t.float :percent_joined_current
      t.float :percent_joined_30_days
      t.float :percent_joined_60_days
      t.float :percent_joined_120_days

      t.float :percent_retained_post_activation_30_days
      t.float :percent_retained_post_activation_60_days
      t.float :percent_retained_post_activation_120_days
      t.float :average_tile_creation_time
      t.timestamps
    end
  end
end
