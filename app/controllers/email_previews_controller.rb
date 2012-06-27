class EmailPreviewsController < ApplicationController
  
  skip_before_filter :authorize
  
  include EmailPreviewsHelper
  
  def invitation
    
    kermit = User.where(:name => Tutorial.example_search_name).first
    code = params[:code]
    referrer_id = params[:referrer_id]
    @user = User.find_by_invitation_code(code) 
    unless @user
      @user = kermit
    end
    @demo_name = @user.demo.name
    if referrer_id
      @referrer = User.where(:id => referrer_id).first
    end
    @referrer_hash = User.referrer_hash(@referrer)
    @play_now_url = invitation_url(@user.invitation_code, @referrer_hash)
    @style = EmailStyling.new(get_image_url)
    @preview_url = invitation_preview_url_with_referrer(@user, @referrer, @style.image_url)
    @hide_browser_option = true if code
    render :file => 'mailer/invitation.html.haml', :layout => 'mailer'
  end
  

end
