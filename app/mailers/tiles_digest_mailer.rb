# frozen_string_literal: true

class TilesDigestMailer < BaseTilesDigestMailer
  def notify_one(digest, user_id, subject, presenter_class)
    @user = User.includes(:board_memberships).find_by(id: user_id)
    return nil unless @user && @user.email.present?

    @demo = digest.demo
    @tile_ids = tile_ids_for_digest(digest)
    return nil unless @tile_ids.present?

    @presenter = presenter_class.constantize.new(digest, @user, subject)

    @tiles = tiles_by_position

    if digest.include_sms && should_deliver_text_message?(@user, @demo)
      SmsSenderJob.perform_now(to_number: @user.phone_number, from_number: @demo.twilio_from_number, body: @presenter.body_for_text_message(@tile_ids[0]))
    end

    x_smtpapi_unique_args = @demo.data_for_mixpanel(user: @user).merge(
      subject: subject,
      digest_id: digest.id,
      email_type: @presenter.email_type
    )

    set_x_smtpapi_headers(category: @presenter.email_type, unique_args: x_smtpapi_unique_args)

    mail to: @user.email_with_name, from: @presenter.from_email, subject: subject
  end

  private

    def should_deliver_text_message?(user, demo)
      bm = user.board_memberships.where(demo_id: demo.id).first
      bm.receives_text_messages
    end

    def tile_ids_for_digest(digest)
      if digest.id == "test"
        digest.tile_ids
      else
        digest.tile_ids_for_user(@user)
      end
    end
end
