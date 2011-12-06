class ScoresController < ApplicationController
  respond_to :js

  def index
    @demo  = current_user.demo
    @users = @demo.users.claimed.order('points DESC')

    if (@show_only = params[:show_only]) == 'following'
      @users = @users.joins("INNER JOIN friendships ON friend_id = users.id").where("friendships.user_id = ?", current_user.id)
    end

    @active_scoreboard_tag = @show_only ? "Fan Of" : "All"

    @show_all = params[:show_all]
    unless @show_all
      @users = @users.with_ranking_cutoff
    end
  end
end
