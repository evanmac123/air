module NavigationHelpers
  # Put helper methods related to the paths in your application here.

  def homepage
    "/"
  end

  def new_session_page
    "/session/new"  
  end

  def signin_page
    '/sign_in'
  end

  def marketing_page
    "/"
  end

  def invitation_page(user)
    invitation_path(user.invitation_code)
  end

  def activity_page
    "/activity"
  end

  def acts_page
    "/acts"
  end

  def profile_page(user)
    user_path(user.slug)
  end

  def should_be_on(expected_path)
    current_path = URI.parse(current_url).path
    current_path.should == expected_path
  end
end

RSpec.configuration.include NavigationHelpers, :type => :acceptance
