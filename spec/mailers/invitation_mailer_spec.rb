require "spec_helper"

describe Mailer do
  it '#invitation contains a do-not-forward warning message' do
    email = Mailer.invitation(FactoryGirl.create :user)
    expect(email.text_part.body).to include('Please do not forward it to others.')
  end
  it '#invitation contains link for ie in footer' do
  	user = FactoryGirl.create :user
    email = Mailer.invitation(user)

    expect(email.html_part.body).to include("If using a web browser that's IE8 or below, copy and paste this link into IE8 and above, Firefox or Chrome:")
    expect(email.html_part.body).to include("http://www.example.com/invitations/#{user.invitation_code}")
  end
end
