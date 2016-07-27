#source http://stackoverflow.com/questions/19093487/ruby-create-range-of-dates

require 'active_support/all'
class RailsDateRange < Range
  # step is similar to DateTime#advance argument
  def every(step, &block)
    c_date = self.begin.to_date
    finish_time = self.end.to_date
    foo_compare = self.exclude_end? ? :< : :<=

    arr = []
    while c_date.send( foo_compare, finish_time) do 
      arr << c_date
      c_date = c_date.advance(step)
    end
    return arr
  end
end
