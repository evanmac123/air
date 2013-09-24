class Invitation::AutocompletionsController < ApplicationController
  skip_before_filter :authorize
  def index
    text = params[:entered_text].strip.downcase

    if current_user # This means you're logged in and want to find invitees
      demo = current_user.demo
      names  = User.get_users_where_like(text, demo, "name", current_user)
      slugs  = User.get_users_where_like(text, demo, "slug", current_user)
    else            # This means you're trying to sign up and want to locate a referrer
      begin
        email = params[:email].strip.downcase
        demo = User.find_by_email(email).demo
        names  = User.get_claimed_users_where_like(text, demo, "name")
        slugs  = User.get_claimed_users_where_like(text, demo, "slug")
      rescue
        # This line will get called if my login cookie has expired
        render 'shared/ajax_refresh_page' and return
      end
    end

    names = names.limit(5)
    slugs = slugs.limit(5)

    @matched_users = names
    slugs.each do |s|
      @matched_users << s unless @matched_users.include? s
    end
    current_user_or_new_user = current_user ? current_user : User.find_by_email(email)
    @matched_users.reject! {|ff| ff == current_user_or_new_user}
    @matched_users = @matched_users[0,5]


    render :layout => false
  end



end 
