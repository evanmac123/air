class Mailer < ActionMailer::Base
  has_delay_mail

  include EmailPreviewsHelper # Only includes the module for this controller (not for the views)
  helper :email  # loads app/helpers/email_helper.rb & includes EmailHelper into the VIEW

  default :from => "H Engage <play@playhengage.com>"
  
  def invitation(user, referrer = nil, options = {})
    demo = user.demo
    email_template = demo.invitation_email
    referrer_hash = User.referrer_hash(referrer)

    @invitation_url = if options[:password_only]
                       user.manually_set_confirmation_token
                       edit_user_password_url(user, :token => user.confirmation_token) 
                     else
                       invitation_url(user.invitation_code, referrer_hash)
                     end

    @plain_text = email_template.plain_text(user, referrer, @invitation_url)
    @html_text = email_template.html_text(user, referrer, @invitation_url).html_safe
    @user = user

    mail(:to      => user.email_with_name,
         :subject => email_template.subject(user, referrer, @invitation_url),
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


  def activity_report(csv_data, demo_name, report_time, address)
    # Convert spaces to '_'s and remove any garbage characters
    normalized_name = demo_name.gsub(/\s+/, '_').gsub(/[^A-Za-z0-9_]/, '')
    attachment_name = normalized_name + '_' + report_time.strftime("%Y_%m_%d_%H%M") + '.csv'

    attachments[attachment_name] = csv_data

    mail :to      => address,
         :subject => "Activity dump for #{demo_name} as of #{report_time.pretty}"
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

  def follow_notification(friend_name, friend_address, reply_address, user_name, user_id, friendship_id)
    @friend_name   = friend_name.split[0]
    @user_name     = user_name
    @user_id       = user_id
    @friendship_id = friendship_id

    mail :to      => friend_address,
         :from    => reply_address,
         :subject => "#{user_name} wants to be your friend on H Engage"
  end

  def follow_notification_acceptance(user_name, user_address, reply_address, friend_name)
    @user_name   = user_name.split[0]
    @friend_name = friend_name

    mail :to      => user_address,
         :from    => reply_address,
         :subject => "Message from H Engage"
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

  def side_message(recipient_identifier, message, options = {})
    to_email, from_email = case recipient_identifier
                           when Fixnum
                             @user = User.find(recipient_identifier)
                             [@user.email, @user.reply_email_address]
                           when String
                             [recipient_identifier, DEFAULT_PLAY_ADDRESS]
                           end

    @message = construct_reply(message.dup)
    @just_message = options[:just_message]

    mail :to      => to_email,
         :from    => from_email,
         :subject => "Message from H Engage",
         :template_path => 'email_command_mailer',
         :template_name => "send_response"
  end

  def fuji_snafu_response(recipient)
    mail :to => recipient,
         :from => 'fuji@playhengage.com',
         :subject => "We received your submission"
  end
end
