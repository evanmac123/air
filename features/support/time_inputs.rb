def set_time_inputs(input_prefix, time_string)
  month,day,year,hour,minute = time_string.split("/")
  {"1i" => year, "2i" => month, "3i" => day, "4i" => hour, "5i" => minute}.each do |input_suffix, value|
    select value, :from => "#{input_prefix}_#{input_suffix}"
  end
end
