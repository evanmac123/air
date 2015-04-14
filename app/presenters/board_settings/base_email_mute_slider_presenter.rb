class BaseEmailMuteSliderPresenter
  include Rails.application.routes.url_helpers  
  
  def initialize(board_id, digest_is_muted, original_setting)
    @board_id = board_id
    @digest_is_muted = digest_is_muted
    @original_setting = original_setting
  end

  def wrapper_classes
    return @wrapper_classes if @wrapper_classes.present?
    @wrapper_classes = %w(switch round)
    @wrapper_classes << "#{email_type}_wrapper"
    @wrapper_classes << "disabled" if self.disabled?
    @wrapper_classes
  end

  def paddle_classes
    return @paddle_classes if @paddle_classes.present?
    @paddle_classes = %w(green-paddle)
    @paddle_classes << "disabled" if self.disabled?
    @paddle_classes
  end

  def mute_class
    @mute_class ||= "#{email_type}_mute"
  end

  def unmute_class
    @unmute_class ||= "#{email_type}_unmute"
  end

  def radio_button_name
    @radio_button_name ||= "mute_#{email_type}_#{board_id}"  
  end

  def wrapper_data
    {board_id: self.board_id}  
  end

  def radio_data
    {mute_url: self.mute_url, board_id: self.board_id}  
  end

  def cache_key
    @cache_key ||= [
      self.class,
      'v2.pwd',
      self.board_id,
      self.digest_is_muted,
      self.original_setting,
      self.disabled?
    ].join('-')
  end

  attr_reader :board_id, :digest_is_muted, :original_setting
end
