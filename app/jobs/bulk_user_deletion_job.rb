class BulkUserDeletionJob

  def initialize params

    @demo_id = params[:demo_id]
    @demo = Demo.find(params[:demo_id])
    @ordinary_users = params[:ordinary_users].present?
    @include_client_admins = params[:client_admins].present?
  end

  def perform
    Rails.logger.info("!!!! Batch Deleting users from: #{@demo.name} - include client admins: #{@include_client_admins}")
    Rails.logger.info("!!!! ----------------------------------------")
    users_to_delete.find_each(batch_size: 100) do|user|
      Rails.logger.info("!!!! Deleting Users: #{user.name} with id #{user.id}")
      user.destroy unless user.is_site_admin?
    end
  end

  def users_to_delete
    User.joins(:board_memberships).where("board_memberships.demo_id =?", @demo_id).where(users_to_delete_condition)
  end

  def users_to_delete_condition
     case
     when @ordinary_users && @include_client_admins
       ""
     when @ordinary_users && @include_client_admins == false
       "board_memberships.is_client_admin is false"
     when @include_client_admins && @ordinary_users == false
       "board_memberships.is_client_admin is true"
     end
  end

  handle_asynchronously :perform
end
