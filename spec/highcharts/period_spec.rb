require "spec_helper"

describe Period do
  context "#q_start_date" do
    xit "should return right q_start_date" do
      period = Period.new 'hourly', "Sep 18, 2015", "Sep 18, 2015"
      p period.q_start_date
    end
  end

  context "#q_end_date" do
    xit "should return right q_end_date" do
      period = Period.new 'hourly', "Sep 18, 2015", "Sep 18, 2015"
      p period.q_end_date
    end
  end
end
