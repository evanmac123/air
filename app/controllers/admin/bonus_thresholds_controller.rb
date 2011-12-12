class Admin::BonusThresholdsController < AdminBaseController
  before_filter :find_demo_by_demo_id, :only => [:new, :create]
  before_filter :find_bonus_threshold, :only => [:edit, :update, :destroy]

  def new
    @bonus_threshold = @demo.bonus_thresholds.new
    render :template => 'admin/bonus_thresholds/form'
  end

  def create
    @bonus_threshold = @demo.bonus_thresholds.new(params[:bonus_threshold])

    if @bonus_threshold.save
      flash[:success] = "Bonus threshold created"
    else
      flash[:failure] = "Couldn't create bonus threshold: #{@bonus_threshold.errors.full_messages}"
    end

    redirect_to admin_demo_path(@demo.id)
  end

  def edit
    render :template => 'admin/bonus_thresholds/form'
  end

  def update
    @bonus_threshold.attributes = params[:bonus_threshold]
    if @bonus_threshold.save
      flash[:success] = 'Bonus threshold updated'
    else
      flash[:failure] = "Couldn't update bonus threshold: #{@bonus_threshold.errors.full_messages}"
    end

    redirect_to admin_demo_path(@bonus_threshold.demo_id)
  end

  def destroy
    @bonus_threshold.destroy
    flash[:success] = "Bonus threshold deleted"
    redirect_to admin_demo_path(@bonus_threshold.demo)
  end

  protected

  def find_bonus_threshold
    @bonus_threshold = BonusThreshold.find(params[:id])
  end
end
