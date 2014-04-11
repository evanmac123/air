class BoardNameValidationsController < ApplicationController
  include NormalizeBoardName

  def show
    board_name = normalize_board_name(params[:id])
    existing_demo = Demo.where("name ILIKE ?", board_name)
    render json: {nameValid: existing_demo.empty?}
  end
end
