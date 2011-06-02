class Admin::DemosController < AdminBaseController
  def new
    @demo = Demo.new
    @demo.bonus_thresholds = [BonusThreshold.new]
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

    bonus_thresholds_params = params[:demo].delete(:bonus_thresholds)

    Demo.transaction do
      @demo = Demo.new(params[:demo])
      @demo.save

      bonus_thresholds_params.values.each do |value|
        next if value[:threshold].blank? || value[:max_points].blank?

        @demo.bonus_thresholds.create!(value)
      end
    end

    flash[:success] = "Demo created."
    redirect_to admin_demo_path(@demo)
  end

  def show
    @demo  = Demo.find(params[:id])
    @users = @demo.users.alphabetical
    @user_with_mobile_count = @demo.users.where("phone_number IS NOT NULL AND phone_number != ''").count
    @bonus_thresholds = @demo.bonus_thresholds.in_threshold_order
  end
end
