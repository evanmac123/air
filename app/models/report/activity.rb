require 'csv'

class Report::Activity
  def initialize(game_specifier)
    @demo = Demo.where(["name = ? OR id = ?", game_specifier.to_s, game_specifier.to_i]).first

    unless @demo
      raise ArgumentError, "No demo found with company name or ID \"#{game_specifier}\""
    end
  end

  def report_csv
    (header_line + "\n" + csv_data_per_act.join("\n")).strip + "\n"
  end

  def email_to(addresses)
    csv_data = report_csv
    report_time = Time.now

    addresses.split(/,/).each do |address|
      Mailer.delay.activity_report(csv_data, @demo.name, report_time, address)
    end
  end

  protected

  def demo_acts
    @demo.acts.order('created_at ASC')  
  end

  def data_for_act(act)
    description = (act.rule.try(:primary_value).try(:value)) || act.text
    date = act.created_at.strftime("%Y-%m-%d")
    hour = act.created_at.strftime("%H")
    minute = act.created_at.strftime("%M")
    second = act.created_at.strftime("%S")
    [date, hour, minute, second, act.user.name, description]
  end

  def csv_data_per_act
    demo_acts.map{|act| CSV.generate_line(data_for_act(act)).gsub("\n", "")}
  end
  
  def header_line
    ""
  end
end
