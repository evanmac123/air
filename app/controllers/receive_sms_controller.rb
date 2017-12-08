class ReceiveSmsController < ActionController::Base
  def create
    phone_number = params[:From]
    user = User.where(phone_number: phone_number).first
    output = process_message(params[:Body], user)

    respond(output)
  end

  private

    def respond(message)
      response = Twilio::TwiML::MessagingResponse.new
      response.message do |m|
        m.body(message)
      end

      render xml: response.to_s
    end

    def process_message(message, user)
      if message =~ /stop/i && user.present?
        user.current_board_membership.update_attributes(notification_pref_cd: BoardMembership.notification_prefs[:email])
        output = "Thanks for replying. You will no longer recieve texts from #{from_name(user)}."
      elsif message =~ /start/i
        if user.present?
          user.current_board_membership.update_attributes(notification_pref_cd: BoardMembership.notification_prefs[:both])
          output = "Thanks for replying. You will now recieve text messages from #{from_name(user)}."
        else
          output = "Sorry, we don't have your number in our system."
        end
      else
        output = "Thanks for replying to #{from_name(user)}. Available commands are: 'start' and 'stop'."
      end
      return output
    end

    def from_name(user)
      if user.present?
        user.demo.name
      else
        "Airbo"
      end
    end
end
