class ClientAdmin::PrizesController < ClientAdminBaseController
  before_filter :find_raffle

  def find_raffle
    @demo = current_user.demo
    Raffle.new(demo: @demo).save(validate: false) unless @demo.raffle
    @raffle = @demo.reload.raffle
  end

  def index
  end

  def save_draft
    @raffle.update_attributes_without_validations(raffle_params)
  end

  def update
    @raffle.update_attributes(raffle_params)
  end

  def start
    if @raffle.update_attributes(raffle_params)
      @raffle.update_attribute(:status, Raffle::LIVE)
      flash.delete(:failure)
    else
      flash[:failure] = "Sorry, we couldn't start the raffle: " + @raffle.errors.values.join(", ") + "."
    end
    render 'index'
  end

  def cancel
    @raffle.destroy
    @demo.reload
    find_raffle
    render 'index'
  end

  def raffle_params
    raffle = params[:raffle]
    raffle[:prizes].reject!(&:empty?)
    raffle[:starts_at] =  DateTime.strptime(raffle[:starts_at] + " 00:00", "%m/%d/%Y %H:%M").change(:offset => "-0400") if raffle[:starts_at].present?
    raffle[:ends_at] =  DateTime.strptime(raffle[:ends_at] + " 23:59", "%m/%d/%Y %H:%M").change(:offset => "-0400") if raffle[:ends_at].present?
    raffle
  end
end
