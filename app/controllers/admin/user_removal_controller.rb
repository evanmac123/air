# frozen_string_literal: true

class Admin::UserRemovalController < AdminBaseController
  def index
    @demo = Demo.find(params[:demo_id])
    @users = @demo.users
  end
end
