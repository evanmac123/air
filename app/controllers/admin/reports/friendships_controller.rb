class Admin::Reports::FriendshipsController < ApplicationController

  def show
    @demo = Demo.find(params[:demo_id])
  end

end
