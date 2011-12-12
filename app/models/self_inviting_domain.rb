class SelfInvitingDomain < ActiveRecord::Base
  belongs_to :demo
  validates_uniqueness_of :domain
  validates_presence_of :demo_id, :domain
end
