class Mailer < ActionMailer::Base
  default :from => "H Engage <play@playhengage.com>"

  def invitation(user, referrer = nil)
    @user = user
    @referrer = referrer
    if @referrer
      @referrer_params = "?referrer_id=#{@referrer.id}"
    else
      @referrer_params = ''
    end

    @demo_name = user.demo.name || "H Engage"
    begins = user.demo.begins_at
    if begins
      @demo_begins_at = user.demo.begins_at.to_date.as_pretty_date
      if begins < Time.now
        @already_started = true 
      else
        @begins_soon = true
      end
    end

    subject = "Invitation to play #{@demo_name}"
    mail :to      => user.email,
         :subject => subject,
         :from => @user.reply_email_address
  end

  def victory(user)
    @user = user

    mail :to      => user.demo.victory_verification_email,
         :subject => "HEngage victory notification: #{user.name} (#{user.email})"
  end

  def activity_report(csv_data, name, report_time, address)
    puts "Sending activity report for #{name} to #{address}"

    subject_line = "Activity dump for #{name} as of #{report_time.pretty}"

    normalized_name = name.gsub(/\s+/, '_').gsub(/[^A-Za-z0-9_]/, '')
    attachment_name = [
      normalized_name,
      '-',
      report_time.strftime("%Y_%m_%d_%H%M"),
      '.csv'
    ].join('')

    attachments[attachment_name] = csv_data

    mail :to      => address,
         :subject => subject_line
  end

  def support_request(user_name, user_email, user_phone, game_name, sms_bodies)
    @user_name = user_name
    @user_email = user_email
    @user_phone = user_phone
    @game_name = game_name
    @sms_bodies = sms_bodies

    mail :to      => "support@hengage.com",
         :from    => "support@hengage.com",
         :subject => "Help request from core app for #{@user_name} of #{@game_name} (#{@user_email}, #{@user_phone})"

    headers['Reply-To'] = @user_email
  end

  def follow_notification(to, follower_name, accept_command, ignore_command, reply_phone_number)
    from_address = to.kind_of?(User) ? to.reply_email_address : DEFAULT_PLAY_ADDRESS

    @follower_name = follower_name
    @accept_command = accept_command
    @ignore_command = ignore_command
    @reply_phone_number = reply_phone_number

    mail :to      => to,
         :from => from_address,
         :subject => "#{follower_name} wants to be your friend on H Engage"
  end

  def set_password(user_id)
    @user = User.find(user_id)

    mail :to      => @user.email,
         :from => @user.reply_email_address,
         :subject => "Set your password"
  end

  def already_claimed(to, user_id)
    @user = User.find(user_id)

    mail :to      => to,
         :from => @user.reply_email_address,
         :subject => "ID already taken"
  end

  def side_message(recipient_identifier, message)
    to_email, from_email =
      case recipient_identifier
      when Fixnum
        @user = User.find(recipient_identifier)
        [@user.email, @user.reply_email_address]
      when String
        [recipient_identifier, DEFAULT_PLAY_ADDRESS]
      end

    @message = construct_reply(message.dup)

    mail(
      :to      => to_email,
      :from    => from_email,
      :subject => "Message from H Engage",
      :template_path => 'email_command_mailer',
      :template_name => "send_response")
  end

  def fuji_poke(user_id)
    @user = User.find(user_id)
    mail(
      :to      => @user.email,
      :from    => @user.reply_email_address
    )
  end
end
