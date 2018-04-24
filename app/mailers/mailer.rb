# frozen_string_literal: true

class Mailer < ApplicationMailer
  include EmailPreviewsHelper # TODO: DEPRECATE This module is useless
  layout false
  helper :email  # loads app/helpers/email_helper.rb & includes EmailHelper into the VIEW

  default from: "Airbo <play@ourairbo.com>",
          reply_to: "support@airbo.com"

  def invitation(user, referrer = nil, options = {})
    @demo = options[:demo_id].present? ? Demo.find(options[:demo_id]) : user.demo
    referrer_hash = User.referrer_hash(referrer)

    if options[:password_only]
      user.manually_set_confirmation_token
      invitation_url = edit_user_password_url(user, token: user.confirmation_token)
    else
      invitation_url = invitation_url(user.invitation_code, referrer_hash.merge(demo_id: @demo.id))
    end

    @not_show_settings_link = true
    @user = user
    @presenter = OpenStruct.new(
      general_site_url: invitation_url,
      cta_message: "Start",
      email_heading: "You are invited to join #{@demo.name}",
      custom_message: @demo.intro_message
    )

    mail(
      to: user.email_with_name,
      subject: "You are invited to join #{@demo.name}",
      from: @demo.reply_email_address,
      template_path: "mailer",
      template_name: "system_email"
    )
  end

  def follow_notification(friend_name, friend_address, reply_address, user_name, user_id, friendship_id)
    @user = User.find(user_id)
    @demo = @user.demo
    @presenter = OpenStruct.new(
      general_site_url: accept_friendship_url(user_id, friendship_id),
      cta_message: "Accept",
      email_heading: "Connection request",
      custom_message: "Hi #{friend_name.split[0]}, #{user_name} has asked to be your connection on Airbo."
    )

    mail(
      to: friend_address,
      from: reply_address,
      subject: "#{user_name} wants to be your friend on Airbo",
      template_path: "mailer",
      template_name: "system_email"
    )
  end

  def follow_notification_acceptance(user_name, user_address, reply_address, friend_name, friend_id)
    friend = User.find(friend_id)
    @user = User.find_by(email: user_address)
    @demo = @user.demo
    @presenter = OpenStruct.new(
      general_site_url: email_friend_url(friend, @user),
      cta_message: "See your new connection",
      email_heading: "Connection accepted",
      custom_message: "Hi #{user_name.split[0]}, #{friend_name} has approved your connection request."
    )

    mail(
      to: user_address,
      from: reply_address,
      subject: "Message from Airbo",
      template_path: "mailer",
      template_name: "system_email"
    )
  end

  def guest_user_converted_to_real_user(user)
    @user = user
    @demo = @user.demo
    @presenter = OpenStruct.new(
      general_site_url: cancel_account_url(id: user.cancel_account_token),
      cta_message: "Cancel",
      email_heading: "Welcome to Airbo!",
      custom_message: "Welcome to the  #{@demo.name} on Airbo\nIf you didn't create this account, just click here to cancel"
    )

    mail(
      to: user.email_with_name,
      from: user.reply_email_address,
      subject: "Welcome to Airbo!",
      template_path: "mailer",
      template_name: "system_email"
    )
  end

  def notify_creator_for_social_interaction(tile, user, action)
    @creator = tile.creator || tile.original_creator
    return unless @creator.present?

    @demo = @creator.demo
    @user = user
    @presenter = OpenStruct.new(
      general_site_url: explore_tile_preview_url(tile),
      cta_message: "See Tile",
      email_heading: "Congratulations!",
      custom_message: "#{@user.name} #{action} your tile \"#{tile.headline},\" that you shared on the Explore page."
    )

    mail(
      to: @creator.email_with_name,
      from: @creator.reply_email_address,
      subject: "Someone #{action} your tile on Airbo",
      template_path: "mailer",
      template_name: "system_email"
    )
  end

  def change_password(user)
    @user = user
    @demo = user.demo
    @presenter = OpenStruct.new(
      general_site_url: edit_user_password_url(@user, token: @user.confirmation_token.html_safe),
      cta_message: "Change password",
      email_heading: "Change your password",
      custom_message: "Someone, hopefully you, has requested that we send you a email to change your password. Click button if you want to do this. If you didn't request this, ignore this email, your password hasn't been changed."
    )

    mail(
      to: @user.email,
      from: @user.reply_email_address,
      subject: "Change your password",
      template_path: "mailer",
      template_name: "system_email"
    )
  end
end
