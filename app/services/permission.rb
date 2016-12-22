def authorized?
  current_permission.allow?
end

def current_permission
  @current_permission ||= Permission.new(current_user, params[:controller], params[:action])
end

class Permission
  extend Forwardable

  def_delegators :user,
    :id

  def initialize(user, controller, action)
    @_user = user || User.new
    @_controller = controller
    @_action = action
  end

  def allow?
    case
    when is_site_admin
      site_admin_permissions
    when is_client_admin
      client_admin_permissions
    when user_onboarding
      onboarding_permissions
    when is_end_user
      user_permissions
    when is_a?(PotentialUser)
      potential_user_permissions
    else
      guest_permissions
    end
  end

  private
    def user
      @_user
    end

    def controller
      @_controller
    end

    def action
      @_action
    end

    def site_admin_permissions
      return true
    end

    def client_admin_permissions
      return true if controller == 'example' && action.in?(%w(index))
    end

    def onboarding_permissions
      return true if controller == "client_admin/reports"
      return true if controller == "client_admin/board_stats_grid"
    end

    def user_permissions
      return true if controller == 'example' && action.in?(%w(index))
    end

    def potential_user_permissions
      return true if controller == 'example' && action.in?(%w(index))
    end

    def guest_permissions
    end
end
