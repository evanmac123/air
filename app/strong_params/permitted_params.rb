class PermittedParams 
  include Params::User
  include Params::Demo
  attr_accessor :current_user,:params 
  def initialize (params, current_user)
   @current_user = current_user || User.new
   @params = params
  end

end
