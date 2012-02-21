class SelfInvitingDomain < ActiveRecord::Base
  belongs_to :demo
  validates_uniqueness_of :domain
  validates_presence_of :demo_id, :domain
  validates_format_of :domain, :with => /^[a-z0-9.\-]+\.[a-z]{2,4}$/
end
