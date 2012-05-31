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
      @referrer = User.find(referrer_id)
    else
      @referrer = kermit
    end
    @referrer_params = User.referrer_params(@referrer)
    
    @style = EmailStyling.new(get_image_url)
    @hide_browser_option = true if code
    render :file => 'mailer/invitation.html.haml', :layout => 'mailer'
  end
  

end
