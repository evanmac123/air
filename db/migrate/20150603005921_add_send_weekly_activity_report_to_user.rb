class AddSendWeeklyActivityReportToUser < ActiveRecord::Migration
  def change
    add_column :users, :send_weekly_activity_report, :boolean
  end
end
