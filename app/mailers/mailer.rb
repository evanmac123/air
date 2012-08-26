class Mailer < ActionMailer::Base
  include EmailPreviewsHelper # Only includes the module for this controller (not for the views)
  helper :email  # loads app/helpers/email_helper.rb & includes EmailHelper into the VIEW

  default :from => "H Engage <play@playhengage.com>"
  
  def invitation(user, referrer = nil, options = {})
    demo = user.demo
    email_template = demo.invitation_email
    referrer_hash = User.referrer_hash(referrer)

    invitation_url = if options[:password_only]
                       user.manually_set_confirmation_token
                       edit_user_password_url(user, :token => user.confirmation_token) 
                     else
                       invitation_url(user.invitation_code, referrer_hash)
                     end

    @plain_text = email_template.plain_text(user, referrer, invitation_url)
    @html_text = email_template.html_text(user, referrer, invitation_url).html_safe
    @user = user

    mail(:to      => user.email_with_name,
         :subject => email_template.subject(user, referrer, invitation_url),
         :from    => demo.reply_email_address)  
  end


  def easy_in(user)

    @user = user
    @user.manually_set_confirmation_token
    @check_it_out_url = invitation_url(@user.invitation_code, :easy_in => true) 
    @set_password_url = edit_user_password_url(@user, :token => @user.confirmation_token, :protocol => (Rails.env.development? ? 'http' : 'https'))
    subject = "Wondering what your colleagues are up to in #{@user.demo.name}? Here's an easy way to take a peek"
    mail :to      => user.email_with_name,
         :subject => subject,
         :from    => @user.demo.reply_email_address
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
      :from    => @user.reply_email_address,
      :subject => "Are you in the game?"
    )
  end
end
