require 'spec_helper'

describe SelfInvitingDomain do
  subject {FactoryGirl.create :self_inviting_domain}

  it { should belong_to :demo }
  it { should validate_uniqueness_of :domain }
  it { should validate_presence_of :demo_id }
  it { should validate_presence_of :domain }
  
      
end
