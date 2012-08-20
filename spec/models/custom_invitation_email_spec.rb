require 'spec_helper'

describe CustomInvitationEmail do
  it{ should validate_presence_of(:demo_id) }
end
