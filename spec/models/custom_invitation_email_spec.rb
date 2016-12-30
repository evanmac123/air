require 'spec_helper'

describe CustomInvitationEmail do
  it{ is_expected.to validate_presence_of(:demo_id) }
end
