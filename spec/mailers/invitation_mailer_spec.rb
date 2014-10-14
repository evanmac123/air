require "spec_helper"

describe Mailer do
  it '#invitation contains a do-not-forward warning message' do
    email = Mailer.invitation(FactoryGirl.create :user)
    email.text_part.body.should include('Please do not forward it to others.')
  end
  it '#invitation contains invitation link for ie in footer' do
  	user = FactoryGirl.create :user
    email = Mailer.invitation(user)
    invitation_for_ie = <<CSV
If using below IE8, copy and paste this link into IE8 and above, Firefox or Chrome:
http://www.example.com/invitations/25ac120b0ac929e067ef395f8a84b4a3a9032eff?demo_id=15259
CSV
	invitation_for_ie = <<CSV
Our mailing address is 292 Newbury Street, Suite 547, Boston, MA 02116.
CSV
    email.html_part.body.should include(invitation_for_ie)
  end
end
