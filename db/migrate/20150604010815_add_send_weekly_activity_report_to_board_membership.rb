class AddSendWeeklyActivityReportToBoardMembership < ActiveRecord::Migration
  def change
    add_column :board_memberships, :send_weekly_activity_report, :boolean, default: true
  end
end
