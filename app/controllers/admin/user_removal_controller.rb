# frozen_string_literal: true

class Admin::UserRemovalController < AdminBaseController
  def index
    @demo = Demo.find(params[:demo_id])
  end

  def update
    # BulkUserDeletionJob.new(user_removal_ids).perform
    puts user_removal_ids
    @demo = Demo.find(params[:demo_id])
    flash[:success] = "You bulk Deletion job for users in #{@demo.name} has been triggered"
    redirect_to admin_demo_user_removal_index_path(@demo)
  end

  private
    def user_removal_ids
      remove_user = ["remove", "user"]
      params.keys.reduce([]) do |result, key|
        split_key = key.split("_")
        split_key[0..1] == remove_user ? result.push(split_key.last) : result
      end
    end
end
