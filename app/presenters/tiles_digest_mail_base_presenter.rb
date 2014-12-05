class TilesDigestMailBasePresenter
  STANDARD_DIGEST_HEADING = 'Your New Tiles Are Here!'.freeze
  STANDARD_FOLLOWUP_HEADING = "Don't miss your new tiles".freeze

  def initialize(custom_message)
    @custom_message = custom_message
  end

  def follow_up_email
    false
  end

  def slice_size
    3
  end

  def custom_message_if_present
    custom_message.present? ? custom_message : ''
  end

  def link_options
    {}
  end

  def is_preview
    false
  end

  def is_empty_preview?
    false
  end

  def include_js_and_stylesheet?
    false
  end

  def digest_email_heading
    STANDARD_DIGEST_HEADING
  end

  def works_on_mobile?
    true
  end

  attr_reader :custom_message

  protected

  def join_demo_copy
    "Join my #{@demo.name}"        
  end

  def join_demo_copy_or_digest_email_heading(use_join_demo_copy)
    if use_join_demo_copy
      join_demo_copy
    else
      digest_email_heading
    end
  end
end
