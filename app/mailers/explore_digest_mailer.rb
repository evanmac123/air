class ExploreDigestMailer < BaseTilesDigestMailer
  helper :interpolation
  include InterpolationHelper

  def notify_one(explore_digest, user)
    @user  = user
    return nil unless @user.email.present?

    @presenter = ExploreDigestPresenter.new(@user.explore_token)
    @explore_digest = explore_digest

    subject = get_subject

    x_smtpapi_unique_args = @user.data_for_mixpanel.merge({
      subject: subject,
      digest_id: explore_digest.id,
      email_type: @presenter.email_type
    })

    set_x_smtpapi_headers(category: @presenter.email_type, unique_args: x_smtpapi_unique_args)

    mail to: @user.email_with_name,
      from: @presenter.from_email,
      subject: subject
  end

  def notify_all(explore_digest, users = nil)
    users ||= User.client_admin.where(receives_explore_email: true)
    users.each { |user|
      ExploreDigestMailer.delay.notify_one(explore_digest, user)
    }
  end

  private
    def get_subject
      @explore_digest.defaults(:subject).empty? ? "Airbo Explore" : interpolate!(@explore_digest.defaults(:subject))
    end
end
