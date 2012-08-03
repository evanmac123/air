class EmailPreviewsController < ApplicationController
  
  skip_before_filter :authorize
  
  include EmailPreviewsHelper
  
  def invitation
    
    code = params[:code]
    @user = User.find_by_invitation_code(code) 
    if @user # a real user is viewing this 
      @demo = @user.demo
      referrer_id = params[:referrer_id]
      @referrer = User.where(:id => referrer_id).first if referrer_id
    elsif params[:demo_id] && current_user.try(:is_site_admin) # an admin is previewing
      @demo = Demo.find(params[:demo_id])
      @user = current_user
      @referrer = User.new(name: "Smarty Pants") if params[:referrer]
    else
      redirect_to '404' and return
    end
    @demo_name = @demo.name
    @referrer_hash = User.referrer_hash(@referrer)
    @play_now_url = invitation_url(@user.invitation_code, @referrer_hash)
    @style = EmailStyling.new(get_image_url)
    @preview_url = invitation_preview_url_with_referrer(@user, @referrer, @style.image_url)
    @hide_browser_option = true if code
    render :file => 'mailer/invitation.html.haml', :layout => 'mailer'
  end
  

end
