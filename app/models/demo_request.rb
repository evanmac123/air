class DemoRequest < ActiveRecord::Base
  validates :email, presence: true
end
