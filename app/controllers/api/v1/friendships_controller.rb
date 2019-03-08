# frozen_string_literal: true

class Api::V1::FriendshipsController < Api::ApiController
  before_action :verify_origin

  def index
    render json: if current_user && !current_user.is_guest?
                   sanitize_friendships(current_user.friendships)
                 else
                   []
    end
  end

  private
    def sanitize_friendships(friendships)
      friendships.joins("INNER JOIN users ON users.id = friendships.friend_id")
        .select("users.name", "users.slug AS path", "users.tickets")
        .order("users.name ASC")
        .limit(5)
        .to_json(root: false, only: [:name, :path, :tickets])
    end
end
