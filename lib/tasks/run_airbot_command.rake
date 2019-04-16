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
      friday = Date.new(raw_date[0].to_i, raw_date[1].to_i, adjusted_payday).friday?
      payday_processing = Date.new(raw_date[0].to_i, raw_date[1].to_i, adjusted_payday - (friday ? 4 : 6))
      days_left_until_processing = payday_processing.day - today.day

      if days_left_until_processing == 2 || days_left_until_processing == 1
        text = if days_left_until_processing == 1
          "Payroll is running #{payday_processing.monday? ? 'Monday' : 'tomorrow'} by Noon east coast time.\nPlease send your approved expenses for inclusion."
        else
          "There are just #{days_left_until_processing} more days until payday processing.\nPlease get your expenses in before #{payday_processing.strftime('%A, %B %d')} 12:00pm east coast time."
        end
        Airbot.new.slack_method('chat.postMessage', {
          channel: 'ourbo',
          as_user: 'false',
          attachments: [
            Airbot.msg_attachment(
              title: 'Reminder to Submit Expenses',
              text: text,
              color: "#26d100",
              random_giphy: 'cash money',
              ts: Time.now.to_i
            )
          ]
        })
      end
    end
  end
end
