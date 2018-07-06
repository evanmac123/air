def absolute_value(val)
  if val == "true" || val == "false"
    val == "true"
  elsif val.to_i > 0 || val.to_i < 0 || val == "0"
    val.to_f == val.to_i ? val.to_i : val.to_f
  elsif val == "null"
    nil
  elsif val == nil
    ""
  else
    val
  end
end

def convert_raw_data(data)
  data.reduce({}) do |result, point|
    key_val = point.split("=", 2)
    result[key_val[0].to_sym] = absolute_value(key_val[1])
    result
  end
end

namespace :cypress do
  desc "Create seed data for E2E Cypress testing"
  task :factory, [:model] => :environment do |t, args|
    if ENV["RAILS_ENV"] == "test"
      model = args[:model]
      values = convert_raw_data(args.extras)
      eval(model.capitalize).create!(values)
    end
  end
end
