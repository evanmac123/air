class Admin::Reports::InteractionsController < ApplicationController

  def show
    @demo = Demo.find(params[:demo_id])
    @rules = Rule.where(:demo_id => @demo.id).sort_by(&:description)
    @users = User.claimed.where(:demo_id => @demo.id)
    unless params[:tag_ids].blank?
      filter_tag_ids = params[:tag_ids].strip.split(',').uniq.collect {|id| id.to_i}
      filter_tag_ids.reject! {|t| t == 0}
      filter_tag_ids = Set.new filter_tag_ids
      @rules = @rules.collect do |rule|
        tag_ids_this_rule = Set.new rule.tag_ids_with_primary
        rule if filter_tag_ids.subset? tag_ids_this_rule
      end
      @rules.reject!{|r| r.nil?}
      @js = true
    end 
    rule_ids = @rules.collect do |rule|
      rule.id
    end
    
    @tags = Tag.all

    @num_users_this_demo = @users.count
    @number_rows = @rules.count + 1    
    hist = {}
    
    (@number_rows).times do |count|
      hist[count] = 0
    end
    @max_rules = 12 
    if rule_ids.length <= @max_rules
      @users.each do |user|
        how_many = Act.where(:user_id => user.id, :rule_id => rule_ids).count
        hist[how_many] = hist[how_many] + 1
      end
      @user_usage_data = hist
    else
      @too_many_rules = true
    end
      


    if params[:format] == 'xhr'
      @tables_only = true
      render :layout => false
    end
       
  end

end
