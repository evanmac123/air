class Mailer < ActionMailer::Base
  default :from => "vlad@playhengage.com"

  def invitation(user, referrer = nil)
    @user = user
    @referrer = referrer
    if @referrer
      @referrer_params = "?referrer_id=#{@referrer.id}"
    else
      @referrer_params = ''
    end
    @demo_name = user.demo.name || "H Engage"
    from_email = @user.demo.email || "vlad@playhengage.com"
    mail :to      => user.email,
         :subject => "Invitation to demo H Engage",
         :from => from_email
  end

  def victory(user)
    @user = user

    mail :to      => user.demo.victory_verification_email,
         :subject => "HEngage victory notification: #{user.name} (#{user.email})"
  end

  def activity_report(csv_data, name, report_time, address)
    puts "Sending activity report for #{name} to #{address}"

    subject_line = "Activity dump for #{name} as of #{report_time.to_s}"

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
    @follower_name = follower_name
    @accept_command = accept_command
    @ignore_command = ignore_command
    @reply_phone_number = reply_phone_number

    mail :to      => to,
         :from    => "donotreply@hengage.com",
         :subject => "#{follower_name} wants to be your fan on H Engage"
  end

  def set_password(user_id)
    @user = User.find(user_id)

    mail :to      => @user.email,
         :from    => "donotreply@hengage.com",
         :subject => "Set your password"
  end

  def already_claimed(to, user_id)
    @user = User.find(user_id)

    mail :to      => to,
         :from    => "donotreply@hengage.com",
         :subject => "ID already taken"
  end
end
