# frozen_string_literal: true

class Api::ApiController < ApplicationController
  protect_from_forgery with: :null_session

  def verify_origin
    render json: {} unless request.xhr?
  end

  def relevant_user
    params[:is_guest_user] == "true" ? GuestUser : User
  end

  def find_user_with_params
    relevant_user.find_by(id: params[:user_id]) || PotentialUser.find_by(id: params[:user_id])
  end
end
