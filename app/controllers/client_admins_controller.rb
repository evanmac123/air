class ClientAdminsController < ApplicationController
  must_be_authorized_to :client_admin
  layout "client_admin_layout"

  def show
    # Note that we don't check for a divide-by-zero error since we should 
    # always have at least one claimed user: the very client admin who is
    # looking at this page.

    demo = current_user.demo
    claimed_users = demo.users.claimed

    @claimed_user_count = demo.claimed_user_count
    @with_phone_percentage = demo.claimed_user_with_phone_fraction.as_rounded_percentage
    @with_peer_invitation_fraction = demo.claimed_user_with_peer_invitation_fraction.as_rounded_percentage
  end
end
