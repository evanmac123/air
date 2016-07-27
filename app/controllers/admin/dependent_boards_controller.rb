class Admin::DependentBoardsController < AdminBaseController
  def show
    @demo = Demo.find(params[:demo_id])
    @dependent_board = @demo.dependent_board
  end

  def send_targeted_message
    message = SpouseFollowupService.new(spouse_followup_params)
    message.send_message

    flash[:success] = "Scheduled email to #{message.user_ids.length} users."

    redirect_to admin_demo_dependent_board_path(params[:primary_board])
  end

  private
    def spouse_followup_params
      {
        demo_id: params[:demo_id],
        subject: params[:subject],
        plain_text: params[:plain_text],
        html_text: params[:html_text],
        recipients: params[:recipients]
      }
    end
end
