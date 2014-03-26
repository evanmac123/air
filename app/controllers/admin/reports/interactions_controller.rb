class Admin::Reports::InteractionsController < ApplicationController

  def keepalive
    render :text => "more than one byte"
  end
  
  def show
    @demo = Demo.find(params[:demo_id])
    @rules = Rule.where(:demo_id => @demo.id).sort_by(&:description)
    @users = @demo.users.claimed
    @tags = Tag.all

    rule_ids = @rules.map(&:id)
    

    @num_users_this_demo = @users.count
    @number_rows = @rules.count + 1    
    hist = {}
    
    (@number_rows).times do |count|
      hist[count] = 0
    end

    @max_rules = 2000 # Realized later that the time it takes is dependent on number of users, not number of rules
    if rule_ids.length <= @max_rules
      @users.each do |user|
        how_many = Act.where(:user_id => user.id, :rule_id => rule_ids).count
        hist[how_many] = hist[how_many].nil? ? 1 : hist[how_many] + 1
      end
      @user_usage_data = hist
    else
      @too_many_rules = true
    end
  end
end
