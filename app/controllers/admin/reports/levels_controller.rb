class Admin::Reports::LevelsController < ApplicationController

  def show
    @demo = Demo.find(params[:demo_id])
    @users = User.claimed.where(:demo_id => @demo.id)
    num_users_this_demo = @users.count
    levels_array = Level.where(:demo_id => @demo.id).sort_by(&:index_within_demo)
    levels_array << Level.new(:demo_id => @demo.id, :name => "1", :threshold => 0, :index_within_demo => 1)
    @levels_hash = {}
    levels_array.each do |lev|
      @levels_hash[lev.index_within_demo] = lev
    end
    
    @row_array = []
    counter = 1
    first_time = true
    levels_array.length.times do
      lev = @levels_hash[counter]
      threshold = lev.threshold
      prev_lev = @levels_hash[counter - 1]
      prev_threshold = prev_lev ? prev_lev.threshold : 0
      next_lev = @levels_hash[counter + 1]
      next_threshold = next_lev ? next_lev.threshold : nil
      row = {}
      row[:index]= lev.index_within_demo
      row[:name]= lev.name
      lower_bound = threshold
      upper_bound = next_threshold ? next_threshold - 1 : nil
      row[:points_range] = upper_bound ? "#{lower_bound}-#{upper_bound}" : "#{lower_bound}+"
      num_users = @users.where("users.points >= ? AND users.points <= ?", lower_bound, upper_bound).count
      row[:num_users]= num_users 
      row[:percent_users]= "#{"%.1f" % (100.0 * num_users / num_users_this_demo)}%" 
      @row_array << row
      first_time = false
      counter += 1
    end
    @row_array.reverse!
  end
  
end
