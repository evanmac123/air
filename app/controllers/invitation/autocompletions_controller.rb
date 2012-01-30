class Invitation::AutocompletionsController < ApplicationController
  skip_before_filter :authenticate
  def index
      if current_user # This means you're logged in and want to find invitees
      demo = current_user.demo
      @clear_users_text = "Clear user"
    else            # This means you're trying to sign up and want to locate a referrer
      email = params[:email].strip.downcase
      domain = User.get_domain_from_email(email)
      self_inviting_domain = SelfInvitingDomain.where(:domain => domain).first
      demo = self_inviting_domain.demo
      @clear_users_text = "Clear Users"
    end


    text = params[:entered_text].strip.downcase
    names  = User.get_users_where_like(text, demo, "name")
    slugs  = User.get_users_where_like(text, demo, "slug")
    emails = User.get_users_where_like(text, demo, "email")
    @matched_users = names
    slugs.each do |s|
      @matched_users << s unless @matched_users.include? s
    end
    emails.each do |e|
      @matched_users << e unless @matched_users.include? e
    end
    @matched_users = @matched_users[0,5]


    render :layout => false
  end



end 
