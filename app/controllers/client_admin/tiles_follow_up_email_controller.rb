class ClientAdmin::TilesFollowUpEmailController < ApplicationController

  def destroy
    @follow_up_email = FollowUpDigestEmail.find params[:id]
    @follow_up_email.destroy
  end
end
