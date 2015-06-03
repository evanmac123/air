class MakeSendWeeklyActivityReportDefaultToTrue < ActiveRecord::Migration
	def change
		change_column :users, :send_weekly_activity_report, :boolean, default: true
	end
end
