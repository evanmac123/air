require "spec_helper"

describe Mailer do
  it '#invitation contains a do-not-forward warning message' do
    email = Mailer.invitation(FactoryGirl.create :user)
    email.text_part.body.should include('Please do not forward it to others.')
  end
  it '#invitation contains link for ie in footer' do
  	user = FactoryGirl.create :user
    email = Mailer.invitation(user)

    email.html_part.body.should include("If using below IE8, copy and paste this link into IE8 and above, Firefox or Chrome:")
    email.html_part.body.should include("http://www.example.com/invitations/#{user.invitation_code}")
  end
end
