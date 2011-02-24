class Admin::DemosController < AdminBaseController
  def new
    @demo = Demo.new
  end

  def create
    if (raw_number = params[:demo][:victory_verification_sms_number])
      params[:demo][:victory_verification_sms_number] = PhoneNumber.normalize(raw_number)
    end

    @demo = Demo.new(params[:demo])
    @demo.save
    flash[:success] = "Demo created."
    redirect_to admin_demo_path(@demo)
  end

  def show
    @demo  = Demo.find(params[:id])
    @users = @demo.users.alphabetical
  end
end
