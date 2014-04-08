class BoardNameValidationsController < ApplicationController
  include NormalizeBoardName

  def show
    board_name = normalize_board_name(params[:id])
    existing_demo = Demo.find_by_name(board_name)
    render json: {nameValid: existing_demo.nil?}
  end
end
