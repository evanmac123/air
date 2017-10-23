class TilesDigestMailer < BaseTilesDigestMailer

  def notify_one(digest, user_id, subject, presenter_class)
    @user  = User.where(id: user_id).first
    return nil unless @user && @user.email.present?

    @demo = digest.demo
    @tile_ids = digest.tile_ids_for_email

    @presenter = presenter_class.new(digest, @user, subject, is_invite_user)

    @tiles = TileBoardDigestDecorator.decorate_collection(
      tiles_by_position,
      context: { demo: digest.demo, user: @user, follow_up_email: @presenter.follow_up_email, email_type: @presenter.email_type }
    )

    if digest.include_sms && @user.receives_sms
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

  def notify_all(digest)
    digest.user_ids_to_deliver_to.each_with_index do |user_id, idx|
      subject = resolve_subject(digest.subject, digest.alt_subject, idx)
      TilesDigestMailer.delay.notify_one(digest, user_id, subject, TilesDigestMailDigestPresenter)
    end
  end

  def notify_all_follow_up
    FollowUpDigestEmail.send_follow_up_digest_email.each do |followup|
      followup.delay(run_at: noon).trigger_deliveries
    end
  end

  private

    def resolve_subject(subject, alt_subject, idx)
      return subject unless alt_subject
      idx.even? ? alt_subject : subject
    end

    def is_invite_user
      board_membership = @demo.board_memberships.where(user_id: @user.id).first
      board_membership && !board_membership.joined_board_at.present?
    end
end
