class PermittedParams
  include Params::User
  include Params::Demo

  attr_reader :current_user, :params

  def initialize(params, current_user)
    @current_user = current_user || User.new
    @params = params
  end
end
