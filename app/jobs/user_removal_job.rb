# frozen_string_literal: true

class UserRemovalJob
  def initialize(demo_id:, user_ids:)
    @demo_id = demo_id
    @user_ids = user_ids
  end

  def perform
    log_message(:init_job)
    user_ids.each do |id|
      begin
        BoardMembership.find_by(user_id: id, demo_id: demo_id).destroy
        log_message(:removing, id)
      rescue NoMethodError
        log_message(:err, user)
      end
    end
  end

  handle_asynchronously :perform

  private
    attr_reader :demo_id, :user_ids

    def log_message(type, user_id = nil)
      message = {
        init_job: "!!!! Removing users from: #{demo_id}\n" +
                  "!!!! ----------------------------------------",
        removing: "!!!! Removing user_id: #{user_id}",
        err: "!!!! Error: user #{user_id} not found in demo #{demo_id}"
      }
      Rails.logger.info(message[type])
    end
end
