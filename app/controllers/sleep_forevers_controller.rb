class SleepForeversController < ApplicationController
  skip_before_filter :authenticate

  def show
    # It's not actually forever, but on the Internet, 60 seconds can feel
    # like forever.
    sleep(60)
    render :text => "*yawn* Hey, what's up?"
  end
end
