class ClientAdmin::PrizesController < ClientAdminBaseController
  def index
    @demo = current_user.demo
    @raffle = @demo.raffle
  end

  def save_draft
    @demo = current_user.demo
    @raffle = @demo.raffle
    @raffle.update_attributes_without_validations(raffle_params)
    #  flash[:success] = "Cool!"
    #else
    #  flash[:failure] = "Sorry, we couldn't save draft: " + @raffle.errors.values.join(", ") + "."
    #end
    redirect_to client_admin_prizes_path
  end

  def raffle_params
    raffle = params[:raffle]
    raffle[:prizes].reject!(&:empty?)
    raffle[:starts_at] =  DateTime.strptime(raffle[:starts_at] + " 12:00", "%m/%d/%Y %H:%M").change(:offset => "-0400") if raffle[:starts_at].present?
    raffle[:ends_at] =  DateTime.strptime(raffle[:ends_at] + " 12:00", "%m/%d/%Y %H:%M").change(:offset => "-0400") if raffle[:ends_at].present?
    raffle
  end
end
