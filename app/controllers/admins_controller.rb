class AdminsController < AdminBaseController
  def show
    @current_user = current_user
    @demos = Demo.select("id, name, dependent_board_id, is_paid, (SELECT COUNT(*) FROM board_memberships WHERE demo_id = demos.id) AS user_count").reorder("user_count DESC")
    render template: 'admin/show'
  end
end
