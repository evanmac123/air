require 'csv'

class Report::Activity
  def initialize(demo_id)
    Demo.find(demo_id.to_i)  # Failure to find the requested demo raises an ActiveRecord::RecordNotFound exception
    @demo_id = demo_id       # Gets stuffed in the DelayedJob table/queue => just save the id
  end

  def send_email(addresses)
    demo = Demo.find @demo_id
    addresses.split(/,/).each { |address| Mailer.activity_report(csv_data, demo.name, Time.now, address).deliver }
  end

  protected

  def csv_data
    ("id,location,rule,date" + "\n" + csv_data_per_act.join('')).strip
  end

  def csv_data_per_act
    csv_all_acts = []

    @demo.rule_based_acts.find_each(:batch_size => 1000) { |act| csv_all_acts << CSV.generate_line(act_data(act)) }

    # 1000 records is the default. Specifying just to make clear what we are doing and in case we need to tweak it.
    #Act.find_each(conditions: ["demo_id = ? AND rule_id IS NOT NULL", @demo_id],
    #              batch_size: 1000) do |act|
    #  csv_all_acts << CSV.generate_line(act_data(act))
    #end

    csv_all_acts
  end

  def act_data(act)
    id = act.user_id
    location = act.user.location.try(:name)
    rule = act.rule.primary_value.value
    date = act.created_at.strftime("%m-%d-%Y")

    [id, location, rule, date]
  end
end
