class EmailCommand < ActiveRecord::Base
  belongs_to :user

  module Status
    NEW     = 'new'
    SUCCESS = 'success'
    FAILED  = 'failed'
  end
  STATUSES = [ Status::NEW, Status::SUCCESS, Status::FAILED ]
  validates :status, :inclusion => { :in => STATUSES, :message => "%{value} is not a valid status value" }
  
  
  def create_from_incoming_email(params)
    
  end
  
end
