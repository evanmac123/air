class Api::V1::CheersController < Api::ApiController

  def create
    cheer = Cheer.new(cheer_params)
    render json: { success: cheer.save}
  end

  private

    def cheer_params
      params.require(:cheer).permit(:body)
    end
end
