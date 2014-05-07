class ClientAdmin::PrizesController < ClientAdminBaseController
  before_filter :find_raffle

  def find_raffle
    @demo = current_user.demo
    Raffle.new(demo: @demo).save(validate: false) unless @demo.raffle
    @raffle = @demo.reload.raffle
    @winners = @raffle.winners
  end

  def index
  end

  def save_draft
    @raffle.update_attributes_without_validations(raffle_params)
  end

  def update
    unless @raffle.update_attributes(raffle_params)
      @consolidated_flash = {failure: ["Sorry, we couldn't update the raffle: " + @raffle.errors.values.join(", ") + "."]}
      render 'show_errors'
    end
    @raffle.set_timer_to_end_live
  end

  def start
    if @raffle.update_attributes(raffle_params)
      @raffle.update_attribute(:status, Raffle::LIVE)
      flash.delete(:failure)
      @raffle.set_timer_to_end_live
      #@raffle.delay(run_at: @raffle.ends_at).finish_raffle #2.minutes.from_now
    else
      flash[:failure] = "Sorry, we couldn't start the raffle: " + @raffle.errors.values.join(", ") + "."
    end
    redirect_to client_admin_prizes_path
  end

  def cancel
    @raffle.destroy
    redirect_to client_admin_prizes_path
  end

  def start_new
    @raffle.destroy
    flash[:success] = "All tickets have been cleared from your board and reset for the next prize. This may take a few minutes to finish."
    redirect_to client_admin_prizes_path
  end

  def end_early
    @raffle.update_attribute(:status, Raffle::PICK_WINNERS)
    @raffle.remove_timer_to_end_live
    redirect_to client_admin_prizes_path
  end

  def pick_winners
    if params["number_of_winners"].to_i > 0
      @raffle.update_attribute(:status, Raffle::PICKED_WINNERS)
      @raffle.pick_winners params["number_of_winners"].to_i
      @winners = @raffle.winners
    end
    redirect_to client_admin_prizes_path
  end

  def delete_winner
    @user = User.find(params[:user_id])
    @raffle.winners.delete(@user)
  end

  def repick_winner
    @user = User.find(params[:user_id])
    if @raffle.repick_winner @user
      @new_user = @raffle.raffle_winners.last.user
    else
      render 'delete_winner'
    end
  end

  def raffle_params
    raffle = params[:raffle]
    raffle[:prizes].reject!(&:empty?)
    raffle[:starts_at] =  DateTime.strptime(raffle[:starts_at] + " 00:00", "%m/%d/%Y %H:%M").change(:offset => "-0400") if raffle[:starts_at].present?
    raffle[:ends_at] =  DateTime.strptime(raffle[:ends_at] + " 23:59", "%m/%d/%Y %H:%M").change(:offset => "-0400") if raffle[:ends_at].present?
    raffle
  end
end
