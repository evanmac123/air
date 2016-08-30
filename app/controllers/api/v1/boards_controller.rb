class Api::V1::BoardsController < ApplicationController
  def index
    if params[:search_name]
      @boards = Demo.where(name: params[:search_name])
    end
  end
end
