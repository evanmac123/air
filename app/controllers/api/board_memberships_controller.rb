module Api
  class BoardMembershipsController < Api::UserBaseController
    def update
      @board_membership = current_user.board_memberships.find(params[:id])
      @board_membership.update_attributes(board_membership_params)

      render json: @board_membership
    end

    private

      def board_membership_params
        params.require(:board_membership).permit(:notification_pref_cd)
      end
  end
end
