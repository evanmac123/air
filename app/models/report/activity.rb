require 'csv'

class Report::Activity
  def initialize(demo_id)
    Demo.find(demo_id.to_i)  # Failure to find the requested demo raises an ActiveRecord::RecordNotFound exception
    @demo_id = demo_id       # Gets stuffed in the DelayedJob table/queue => just save the id
  end

  def send_email(address)
    @demo = Demo.find @demo_id

    #csv_data.split("\n").each { |line| p "*** #{line}" }

    Mailer.activity_report(csv_data, @demo.name, Time.now, address).deliver
  end

  protected

  def csv_data
    ("id,location,rule,date" + "\n" + csv_data_per_act.join('')).strip
  end

  # Generate CSV file piecemeal (in batches of 1000) so don't exceed Heroku's memory limitation
  def csv_data_per_act
    csv_all_acts = []
    @demo.rule_based_acts.find_each { |act| csv_all_acts << CSV.generate_line(act_data(act)) }
    csv_all_acts
  end

  def act_data(act)
    id = act.user_id
    location = act.user.location.try(:name)  # Not all users have a location
    rule = act.rule.primary_value.value
    date = act.created_at.strftime("%m-%d-%Y")

    [id, location, rule, date]
  end
end
