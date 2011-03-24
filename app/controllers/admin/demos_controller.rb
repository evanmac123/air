class Admin::DemosController < AdminBaseController
  def new
    @demo = Demo.new
  end

  def create
    %w(custom_welcome_message victory_threshold victory_verification_email victory_verification_sms_number).each do |field_name|
      if params[:demo][field_name].blank?
        params[:demo].delete(field_name)
      end
    end

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
    @user_with_mobile_count = @demo.users.where("phone_number IS NOT NULL AND phone_number != ''").count
    @dummy_user = User.new(:sms_slug => '[sms slug]')
  end
end
