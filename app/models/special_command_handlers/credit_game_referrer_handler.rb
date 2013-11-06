require 'special_command_handlers/base'

class SpecialCommandHandlers::CreditGameReferrerHandler < SpecialCommandHandlers::Base
  def handle_command
    referring_user_sms_slug = @command_name

    demo = @user.demo
    return nil unless demo.credit_game_referrer_threshold && demo.game_referrer_bonus

    referring_user = demo.users.find_by_sms_slug(referring_user_sms_slug)
    return nil unless referring_user

    if referring_user == @user
      return parsing_error_message(I18n.t(
        'special_command.credit_game_referrer.cannot_refer_yourself_sms', 
        :default => "You've already claimed your account, and have %{points}. If you're trying to credit another user, @{say} their Username",
        # for some reason, pluralize works in development but not staging
        # or production
        :points => @user.points.to_s + ' ' + (@user.points == 1 ? 'point' : 'points')
      ))
    end

    referral_deadline = @user.accepted_invitation_at + demo.credit_game_referrer_threshold.minutes 
    if Time.now > referral_deadline
      return parsing_error_message(I18n.t('special_command.credit_game_referrer.too_late_for_game_referral_sms', :default => 'Sorry, the time when you can credit someone for recruiting you is over.'))
    end

    if @user.game_referrer
      return parsing_error_message(I18n.t('special_command.credit_game_referrer.already_referred', :default => "You've already told us that %{referrer_name} recruited you.", :referrer_name => @user.game_referrer.name))
    end

    # If we make it here, we finally know it's OK to credit the referring user.

    parsing_success_message(@user.credit_game_referrer(referring_user))
  end
end
