require 'spec_helper'

describe InvitationRequest do
  it { is_expected.to validate_presence_of(:email).with_message("You must enter your e-mail address to request an invitation.") }
end
