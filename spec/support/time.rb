def sometime_on(date)
  hour_count = rand(23)
  minute_count = rand(60)
  second_count = rand(60)

  date.midnight + hour_count.hours + minute_count.minutes + second_count.seconds
end
