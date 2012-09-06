class Admin::DemosController < AdminBaseController
  before_filter :find_demo_by_id, :only => [:show, :edit, :update, :destroy]
  before_filter :normalize_internal_domains, :only => [:create, :update]

  def new
    @demo = Demo.new
    @demo.levels = [Level.new]
  end

  def create
    levels_params = massage_new_demo_parameters

    begin
      Demo.transaction do
        @demo = Demo.new(params[:demo])
        @demo.save

        create_levels(levels_params)
      end

      flash[:success] = "Demo created."
      redirect_to admin_demo_path(@demo)
    rescue Exception => e
      # Restore level parameters to params so we can see them in Hoptoad later.
     
      params[:demo][:levels] = levels_params

      raise e
    end
  end

  def show
    @users = @demo.users.alphabetical
    @user_with_mobile_count = @demo.users.where("phone_number IS NOT NULL AND phone_number != ''").count
    @claimed_user_count = @demo.users.claimed.count
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

    if @demo.save
      flash[:success] = "Demo updated"
      redirect_to admin_demo_path(@demo)
    else
      flash.now[:failure] = "Couldn't update demo: #{@demo.errors.full_messages.join(', ')}"
      render :edit
    end
  end

  def destroy
    @demo.destroy
    flash[:success] = "#{@demo.name} game destroyed"
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

    params[:demo].delete(:levels)
  end

  def normalize_internal_domains
    internal_domain_string = params[:demo][:internal_domains]
    params[:demo][:internal_domains] = if internal_domain_string.present?
                                         internal_domain_string.split(',').map(&:strip).map(&:downcase)
                                       else
                                         []
                                       end
  end

  def create_levels(levels_params)
    levels_params.values.each do |value|
      next if value.values.all?(&:blank?)
      @demo.levels.create!(value)
    end
  end
end
