class BoardMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :demo
  belongs_to :location

  attr_accessor :role
  before_validation do
    if @role.present?
      self.is_client_admin = self.role == 'Administrator'
    end
    true
  end

  def role
    @role ||= begin
      if self.is_client_admin
        'Administrator'
      else
        'User'
      end
    end
  end
  
  def self.current
    where(is_current: true)
  end
end
