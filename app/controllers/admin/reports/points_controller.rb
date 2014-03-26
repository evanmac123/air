class Admin::Reports::PointsController < ApplicationController
  def show
    @demo = Demo.find(params[:demo_id])
    @users = @demo.users.claimed
    points_array = @users.collect  do |u|
      u.points
    end
    max_points = points_array.max
    increment = 10
    lower_bound = 0
    @points_array = []
    first_time = true
    loop do 
      break if lower_bound > max_points
      if first_time
        upper_bound = lower_bound + increment
      else
        upper_bound = lower_bound + increment - 1
      end
      num_users = @users.where("users.points >= ? AND users.points <= ?", lower_bound, upper_bound).count
      @points_array << "#{lower_bound}-#{upper_bound}|#{num_users}"
      if first_time
        lower_bound += increment + 1
      else
        lower_bound += increment
      end
      first_time = false
    end
    @points_array.reverse!
    @num_users_this_demo = @users.count
    
  end
  
end
