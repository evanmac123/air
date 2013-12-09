module OutgoingMessage
  include ActionView::Helpers::TextHelper

  DEFAULT_SIDE_MESSAGE_DELAY = ENV['SIDE_MESSAGE_DELAY'] || 5

  # See Friendship::FollowNotification for reason as to why doing it this way.
  class SideMessage < Struct.new(:recipient_identifier, :body)
    def perform
      Mailer.side_message(recipient_identifier, body).deliver
    end
  end

  def self.send_message(to, body, send_at = nil, options = {})
    channels = determine_channels(to, options)

    if channels.include?(:sms)
      SMS.send_message(to, body, send_at, options)
    end

    if channels.include?(:email)
      recipient_identifier = to.kind_of?(User) ? to.id : to
      Mailer.delay_mail(:side_message, recipient_identifier, body, options)
    end

    if channels.include?(:web)
      flash_status = options[:flash_status] || :success
      to.add_flash_for_next_request!(body, flash_status)
    end
  end

  def self.send_side_message(to, body, options={})
    send_message(to, body, Time.now + DEFAULT_SIDE_MESSAGE_DELAY, options)
  end

  protected

  def self.determine_channels(to, options)
    if options[:channel].blank?
      default_channels(to)
    else
      [options[:channel].to_sym]
    end
  end

  def self.default_channels(to)
    case to
    when User
      to.notification_channels
    when String
      to.is_email_address? ? [:email] : [:sms]
    end
  end
end
