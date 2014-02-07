class UsersInvite
  extend  ActiveModel::Naming
  extend  ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Validations::Callbacks
  
  attr_accessor :users, :demo_id, :message
  
  validate :validate_users
  validates :demo_id, presence: true
  
  before_validation :transform_users
  
  def initialize(params={})
    params.each do |attr, value|
      self.public_send("#{attr}=", value)
    end if params
  end

  def message
    @message ||= 'Come check out my new board!'
  end

  def persisted?
    false
  end
    
  def self.build(demo_id, num_users = 8)
    user_array = Array.new(num_users)
    user_array.each_index do |index|  
      user_array[index] = User.new(demo_id: demo_id)
    end
    UsersInvite.new(demo_id: demo_id, users: user_array)
  end
  
  def transform_users
    if users.present?
      users.each_with_index do |user_params, index|
        if user_params.is_a?(Hash) && user_params[:name].present? && user_params[:email].present?
          users[index] = User.new(user_params)
          users[index].demo_id = demo_id
          users[index].invitation_method = :client_admin_invites #TODO verify that value is okay/email validation triggered through this
        end
      end
    end
  end
  
  def validate_users
    if users.blank?
      errors.add_on_empty(:users)
    else
      users.each_with_index do |user, index|
        if !user.is_a?(Hash) && !user.valid?
#          errors.add("users[#{index}]", user.errors.full_messages)
          errors.add(user.email, user.errors.full_messages)
        end
      end
    end
  end
  
  def send_invites(from_user)
    if self.valid?
      User.transaction do
        users.each do |user|
          if !user.is_a?(Hash)
            user.save!
            user.invite(from_user, custom_message: message, custom_from: from_user.email_with_name_via_airbo) #mail is sent regardless of transaction succeeded or not, but should never happen
          end
        end
      end
    end
    self
  end
end
