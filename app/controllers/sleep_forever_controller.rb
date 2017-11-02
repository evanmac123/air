class Admin::SleepForeverController < AdminBaseController
  def show
    sleep(60)
    render :text => "Done sleeping, current time is #{Time.current}"
  end
end
