class ClientAdmin::TilesFollowUpEmailController < ApplicationController

  def destroy
    @follow_up_email = FollowUpDigestEmail.find params[:id]
  end
end
