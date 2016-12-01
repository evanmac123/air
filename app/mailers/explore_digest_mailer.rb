class ExploreDigestMailer < BaseTilesDigestMailer
  include Rails.application.routes.url_helpers

  def notify_one(explore_digest, user)
    @user  = user
    return nil unless @user.email.present?

    @presenter = ExploreDigestPresenter.new(@user.explore_token)
    @explore_digest = explore_digest

    subject = @explore_digest.defaults(:subject)

    ping_on_digest_email(@presenter.email_type, @user, subject)

    mail to: @user.email_with_name,
      from: @presenter.from_email,
      subject: subject
  end

  def notify_all(explore_digest, users = nil)
    users ||= User.client_admin
    users.each { |user|
      ExploreDigestMailer.delay.notify_one(explore_digest, user)
    }
  end

  def general_site_url
    if Rails.env.development? or Rails.env.test?
      'http://localhost:3000' + explore_path(explore_token: @explore_token, email_type: email_type)
    else
      explore_url(explore_token: @explore_token, email_type: email_type, host: email_link_host, protocol: email_link_protocol)
    end
  end
end
