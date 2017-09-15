class TilesDigestMailBasePresenter
  attr_reader :custom_message

  STANDARD_DIGEST_HEADING = 'Your New Tiles Are Here!'.freeze
  STANDARD_FOLLOWUP_HEADING = "Don't miss your new tiles".freeze

  def initialize(custom_message)
    @custom_message = custom_message
  end

  def site_link(tile_id: nil)
    general_site_url + subject_line_param.to_s + tile_id_param(tile_id).to_s
  end

  def subject_line_param
    uri_encoded_subject = URI.encode(@subject.to_s, /\W/)
    if uri_encoded_subject.present?
      "&subject_line=#{uri_encoded_subject}"
    end
  end

  def tile_id_param(tile_id)
    if tile_id.present?
      "&tile_id=#{tile_id}"
    end
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

  def digest_email_heading
    STANDARD_DIGEST_HEADING
  end

  def works_on_mobile?
    false
  end

  def email_type
		""
  end

  def general_site_url
    ""
  end

  private

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
