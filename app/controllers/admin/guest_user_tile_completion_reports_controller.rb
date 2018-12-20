# frozen_string_literal: true

class Admin::GuestUserTileCompletionReportsController < AdminBaseController
  def show
    @demo = Demo.find(params[:demo_id])
  end

  def create
    binding.pry
  end
end
