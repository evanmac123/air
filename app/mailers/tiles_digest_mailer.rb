class TilesDigestMailer < BaseTilesDigestMailer

  def notify_one(demo_id, user_id, tile_ids, subject, follow_up_email,
                 custom_headline, custom_message, custom_from=nil, is_new_invite = nil)
    link_subject = sanitize_subject_line(subject)
    @user  = User.find user_id # XTR
    return nil unless @user.email.present?

    @tile_ids = tile_ids
    @demo = Demo.find demo_id

    presenter_class = follow_up_email ? TilesDigestMailFollowUpPresenter : TilesDigestMailDigestPresenter
    @presenter = presenter_class.new(@user, @demo, custom_from, custom_headline, custom_message, is_new_invite, link_subject)


    @tiles = TileBoardDigestDecorator.decorate_collection(
      tiles_by_position,
      context: { demo: @demo, user: @user, follow_up_email: @follow_up_email, email_type:  @presenter.email_type }
    )

    mail  to: @user.email_with_name, from: @presenter.from_email, subject: subject
  end

  def notify_all_follow_up_from_delayed_job
    FollowUpDigestEmail.send_follow_up_digest_email.each do |followup|
      TilesDigestMailer.delay(run_at: noon).notify_all_follow_up(followup.id)
    end
  end

  def notify_all(demo, user_ids, tile_ids, custom_headline, custom_message, subject, alt_subject=nil)
    user_ids.reject! do |user_id|
      BoardMembership.where(demo_id: demo.id, user_id: user_id, digest_muted: true).first.present?
    end

    user_ids.each_with_index do |user_id, idx|
      subj = resolve_subject(subject, alt_subject,idx)
      TilesDigestMailer.delay.notify_one(demo.id, user_id, tile_ids, subj, false, custom_headline, custom_message)
    end
  end

  def notify_all_follow_up(followup_id)
    followup = FollowUpDigestEmail.find followup_id
    followup.trigger_deliveries
    followup.destroy
  end

  def resolve_subject subject, alt_subject, idx
    unless alt_subject
      subject
    else
       idx.even? ? alt_subject : subject
    end
  end

  private

    def sanitize_subject_line(subject)
      if subject
        subject.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      end
    end
end
