class Api::V1::BoardsController < ApplicationController
  def validate_name
    result = !Demo.exists?(name: params[:name])
    render json: result
  end
end
