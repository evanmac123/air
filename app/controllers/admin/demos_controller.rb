class Admin::DemosController < AdminBaseController
  before_filter :find_demo_by_id, :only => [:show, :edit, :update, :destroy]

  def new
    @demo = Demo.new
    @demo.bonus_thresholds = [BonusThreshold.new]
    @demo.levels = [Level.new]
  end

  def create
    bonus_thresholds_params, levels_params = massage_new_demo_parameters

    begin
      Demo.transaction do
        @demo = Demo.new(params[:demo])
        @demo.save

        # TODO: DRY this mess up, maybe wait until we trigger the Rule Of 3.

        create_bonus_thresholds(bonus_thresholds_params)
        create_levels(levels_params)
      end

      flash[:success] = "Demo created."
      redirect_to admin_demo_path(@demo)
    rescue Exception => e
      # Restore bonus threshold and level parameters to params so we can see
      # them in Hoptoad later.
     
      params[:demo][:bonus_thresholds] = bonus_thresholds_params
      params[:demo][:levels] = levels_params

      raise e
    end
  end

  def show
    @users = @demo.users.alphabetical
    @user_with_mobile_count = @demo.users.where("phone_number IS NOT NULL AND phone_number != ''").count
    @bonus_thresholds = @demo.bonus_thresholds.in_threshold_order
    @levels = @demo.levels.in_threshold_order
    @locations = @demo.locations.alphabetical
  end

  def edit
  end

  def update
    %w(victory_verification_email victory_verification_sms_number).each do |nullable_field_name|
      params[:demo][nullable_field_name] = nil if params[:demo][nullable_field_name].blank?
    end

    @demo.attributes = params[:demo]
    @demo.save!

    flash[:success] = "Demo updated"
    redirect_to admin_demo_path(@demo)
  end

  def destroy
    @demo.destroy
    flash[:success] = "#{@demo.company_name} game destroyed"
    redirect_to admin_path
  end

  protected

  def massage_new_demo_parameters
    %w(custom_welcome_message victory_threshold victory_verification_email victory_verification_sms_number).each do |field_name|
      if params[:demo][field_name].blank?
        params[:demo].delete(field_name)
      end
    end

    if (raw_number = params[:demo][:victory_verification_sms_number])
      params[:demo][:victory_verification_sms_number] = PhoneNumber.normalize(raw_number)
    end

    bonus_thresholds_params = params[:demo].delete(:bonus_thresholds)
    levels_params = params[:demo].delete(:levels)

    [bonus_thresholds_params, levels_params]
  end

  %w(bonus_threshold level).each do |associated_object|
    class_eval <<-END_METHOD
      def create_#{associated_object}s(#{associated_object}s_params)
        #{associated_object}s_params.values.each do |value|
          next if value.values.all?(&:blank?)
          @demo.#{associated_object}s.create!(value)
        end
      end
    END_METHOD
  end
end
