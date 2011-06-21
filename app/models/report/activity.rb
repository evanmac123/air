require 'csv'

class Report::Activity
  def initialize(game_specifier)
    @demo = Demo.where(["company_name = ? OR id = ?", game_specifier.to_s, game_specifier.to_i]).first

    unless @demo
      raise ArgumentError, "No demo found with company name or ID \"#{game_specifier}\""
    end
  end

  def report_csv
    lines = @demo.acts.order('created_at ASC').map do |act|
      description = (act.rule.try(:primary_value).try(:value)) || act.text
      date = act.created_at.strftime("%Y-%m-%d")
      hour = act.created_at.strftime("%H")
      minute = act.created_at.strftime("%M")
      second = act.created_at.strftime("%S")
      data = [date, hour, minute, second, act.user.name, description]
      CSV.generate_line(data)
    end

    lines.join("\n") + "\n"
  end

  def email_to(addresses)
    csv_data = report_csv
    report_time = Time.now

    addresses.split(/,/).each do |address|
      Mailer.activity_report(csv_data, @demo.company_name, report_time, address).deliver
    end
  end
end
