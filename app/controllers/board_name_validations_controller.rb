class BoardNameValidationsController < ApplicationController
  def show
    render json: {nameValid: Demo.name_like(params[:id]).empty?}
  end
end
