class FinancialsCalcService
  def initialize curr_date=Date.today
    @today = curr_date 
  end

  def weeks 
    beg_this_week  = curr_date.beginning_of_week(:sunday)

    0..6.map do |week|
      
    end
  end

end
