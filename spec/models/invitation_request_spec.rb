require 'spec_helper'

describe InvitationRequest do
  it { should validate_presence_of(:name).with_message("You must enter your name to request an invitation.") }
  it { should validate_presence_of(:email).with_message("You must enter your e-mail address to request an invitation.") }
end
