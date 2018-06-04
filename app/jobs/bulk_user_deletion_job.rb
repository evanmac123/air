# frozen_string_literal: true

class BulkUserDeletionJob
  def initialize(params)
    @demo_id = params[:demo_id]
    @demo = Demo.find(@demo_id)
    @ordinary_users = params[:ordinary_users].present?
    @include_client_admins = params[:client_admins].present?
  end

  def perform
    log_message type: :init_job
    users_to_delete.find_each(batch_size: 100) do |user|
      log_message type: :removing, user_name: user.name, user_id: user.id
      user.destroy unless user.is_site_admin?
    end
  end

  def users_to_delete
    User.includes(:board_memberships).where("board_memberships.demo_id =?", @demo_id).where(users_to_delete_condition).references(:board_memberships)
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

  def log_message(type:, user_name: nil, user_id: nil)
    message = {
      init_job: "!!!! Batch Deleting users from: #{@demo.name} - include client admins: #{@include_client_admins}\n" +
                "!!!! ----------------------------------------",
      removing: "!!!! Deleting Users: #{user_name} with id #{user_id}"
    }
    Rails.logger.info(message[type])
  end

  handle_asynchronously :perform
end
