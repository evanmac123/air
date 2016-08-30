class Api::V1::BoardsController < ApplicationController
  def index
    # TODO: left as example to discuss API implementations
    @boards = Demo.scoped
  end

  def validate_name
    result = !Demo.exists?(name: params[:name])
    render json: result
  end
end
