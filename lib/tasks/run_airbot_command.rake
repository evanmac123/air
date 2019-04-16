namespace :airbot do
  namespace :scheduled_task do
    desc "Runs scheduled expense report reminder"
    task :send_expense_reminder => :environment do
      today = Date.today
      return unless (1..5).to_a.include?(today.wday)

      raw_date = today.strftime("%Y-%m").split('-')
      payday = today.day > 15 ? Date.civil(raw_date[0].to_i, raw_date[1].to_i, -1).day : today.day
      adjustment = [-2, 0, 0, 0, 0, 0, -1]
      adjusted_payday = payday + adjustment[Date.new(raw_date[0].to_i, raw_date[1].to_i, payday).wday]
      payday_processing = Date.new(raw_date[0].to_i, raw_date[1].to_i, adjusted_payday - 6).day
      days_left_until_processing = payday_processing - today.day

      if days_left_until_processing > 0
        text = if days_left_until_processing == 1
          "Payroll is running tomorrow by Noon east coast time. Please send your approved expenses for inclusion."
        else
          "There are just #{days_left_until_processing} more days until payday processing"
        end
        airbot = Airbot.new
        airbot.slack_method('chat.postMessage', {
          channel: 'DAHC3RACQ',
          as_user: 'false',
          attachments: [
            Airbot.msg_attachment(
              title: 'Reminder to Submit Expenses',
              text: text,
              color: "#26d100",
              random_giphy: 'cash money'
            )
          ]
        })
      end
    end
  end
end
