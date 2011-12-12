class InvitationsController < ApplicationController
  skip_before_filter :authenticate

  before_filter :check_for_name_and_email, :only => :create
  
  def new
  end

  def create
    params[:user][:email] = params[:user][:email].strip.downcase

    find_inviting_domain
    unless @inviting_domain
      render "invalid_inviting_domain"
      return
    end

    User.transaction do
      if User.where(:email => params[:user][:email]).empty?
        @user = User.create!(params[:user].merge(:demo => @inviting_domain.demo))
        @user.invite
      else
        render "duplicate_email"
      end
    end
  end

  def show
    @user = User.find_by_invitation_code(params[:id])
    if @user
      unless @user == current_user
        flash.now[:success] = "You're now signed in."
        sign_in(@user)
      end
    else
      flash[:failure] = "That page doesn't exist."
      redirect_to "/"
    end
  end

  protected

  def check_for_name_and_email
    unless params[:user][:name].present? && params[:user][:email].present?
      flash[:error] = "You must enter your name and e-mail address to request an invitation."
      redirect_to new_invitation_path
    end
  end

  def find_inviting_domain
    @submitted_domain = params[:user][:email].email_domain
    @inviting_domain = SelfInvitingDomain.where(:domain => @submitted_domain).first
  end
end
