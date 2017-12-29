class TilesDigestMailer < BaseTilesDigestMailer

  def notify_one(digest, user_id, subject, presenter_class)
    @user  = User.includes(:board_memberships).find_by(id: user_id)
    return nil unless @user && @user.email.present?

    @demo = digest.demo
    @tile_ids = digest.tile_ids_for_email

    @presenter = presenter_class.constantize.new(digest, @user, subject, is_invite_user)

    @tiles = TileBoardDigestDecorator.decorate_collection(
      tiles_by_position,
      context: { demo: digest.demo, user: @user, follow_up_email: @presenter.follow_up_email, email_type: @presenter.email_type }
    )

    if digest.include_sms && should_deliver_text_message?(@user, @demo)
      SmsSender.send_message(to_number: @user.phone_number, from_number: @demo.twilio_from_number, body: @presenter.body_for_text_message)
    end

    x_smtpapi_unique_args = @demo.data_for_mixpanel(user: @user).merge({
      subject: subject,
      digest_id: digest.id,
      email_type: @presenter.email_type
    })

    set_x_smtpapi_headers(category: @presenter.email_type, unique_args: x_smtpapi_unique_args)

    mail to: @user.email_with_name, from: @presenter.from_email, subject: subject
  end

  private

    def is_invite_user
      board_membership = @demo.board_memberships.where(user_id: @user.id).first
      board_membership && !board_membership.joined_board_at.present?
    end

    def should_deliver_text_message?(user, demo)
      bm = user.board_memberships.where(demo_id: demo.id).first
      bm.receives_text_messages
    end
end
