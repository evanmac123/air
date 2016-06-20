class Admin::CharacteristicsController < AdminBaseController
  before_filter :find_demo
  before_filter :find_characteristic, :only => [:edit, :update, :destroy]
  before_filter :remove_blank_allowed_values, :only => [:create, :update]

  def index
    @characteristics = Characteristic.where(:demo_id => @demo.try(:id))
    @characteristic = Characteristic.new
  end

  def create
    characteristic = Characteristic.create!(params[:characteristic].merge(:demo_id => params[:demo_id]))
    flash[:success] = %{Characteristic "#{characteristic.name}" created}
    redirect_to :back
  end

  def edit
  end

  def update
    @characteristic.update_attributes(params[:characteristic])
    redirect_to(@characteristic.demo ? admin_demo_characteristics_path(@characteristic.demo) : admin_characteristics_path)
  end

  def destroy
    @characteristic.destroy
    redirect_to :back
  end

  protected

  def find_characteristic
    @characteristic = Characteristic.find(params[:id])
  end

  def remove_blank_allowed_values
    params.require(:characteristic).permit!
    params[:characteristic][:allowed_values] = params[:characteristic][:allowed_values].select(&:present?)
  end

  def find_demo
    @demo = Demo.find(params[:demo_id]) if params[:demo_id]
  end
end
