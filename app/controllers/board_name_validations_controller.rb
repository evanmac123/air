class BoardNameValidationsController < UserBaseController
  def show
    render json: {nameValid: Demo.name_like(params[:id]).empty?}
  end
end
