class ActsController < ApplicationController
  include Reply

  layout :determine_layout

  def index
    @current_link_text = "Home"

    @new_appearance = true

    @demo              = current_user.demo
    @demo_user_count   = @demo.ranked_user_count
    @acts              = find_requested_acts(@demo)

    @show_only = params[:show_only]
    @active_tab = params[:show_only].try(:capitalize) || "All"

    respond_to do |format|
      format.html do 
        @users = @demo.users.ranked.with_ranking_cutoff.order('points DESC')
        @levels = current_user.levels.in_demo(current_user.demo).in_threshold_order
      end

      format.js do
        @acts = @acts.offset(params[:offset])
        render :partial => 'shared/new_acts', :locals => {:acts => @acts}
      end
    end
  end

  def create
    parsing_message, parsing_message_type = Command.parse(current_user, params[:act][:code], :return_message_type => true)
    flash[parsing_message_type] = construct_reply(parsing_message)
    redirect_to :back
  end

  protected

  def find_requested_acts(demo)
    acts = demo.acts.recent(10).includes(:user).includes(:rule)

    case params[:show_only]
    when 'following'
      acts.joins("INNER JOIN friendships ON friendships.friend_id = acts.user_id").where(["friendships.user_id = ?", current_user.id])
    when 'mine'
      acts.where(["user_id = ?", current_user.id])
    else
      acts
    end
  end

  def self.channel_specific_translations
    {:say => "Type"}
  end
end
