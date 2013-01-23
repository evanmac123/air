{
  chart_subtitle_range:   "%a, %b %d, %Y",    # Thurs, Jul 04, 2013
  chart_subtitle_one_day: "%A, %B %d, %Y"     # Thursday, July 04, 2013
}.each do |format_name, format_string|
   Time::DATE_FORMATS[format_name] = format_string
end
