namespace :airbot do
  namespace :scheduled_task do
    desc "Runs scheduled expense report reminder"
    task :send_expense_reminder => :environment do
      return unless (1..5).to_a.include?(Date.today.wday)
      airbot = Airbot.new

      airbot.slack_method('chat.postMessage', {
        channel: 'DAHC3RACQ',
        as_user: 'false',
        attachments: [
          Airbot.msg_attachment(
            title: 'Reminder to Submit Expenses',
            text: "There are just x more days until payday processing",
            fallback: "There are just x more days until payday processing",
            color: "#26d100",
            random_giphy: 'money'
          )
        ]
      })
    end
  end
end
