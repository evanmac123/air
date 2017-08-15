class CustomerSuccessKpisMailer < ActionMailer::Base
  def daily_update(report)
    @report = report

    ["nick@airbo.com", "kate@airbo.com"].each do |user|
      mail(from: "Airbo Customer Success<notify@airbo.com>", to: user, subject: "Update: #{report.interval.upcase} Airbo Customer Success KPIs").deliver
    end
  end
end
