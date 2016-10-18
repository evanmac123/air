class UserOnboardingInitializer
  attr_reader :onboarding, :name, :email, :user_onboarding, :error
  def initialize(params)
    @onboarding = Onboarding.find(params[:onboarding_id])
    @email = params[:email]
    @name = params[:name]
  end

  def save
    assemble
  rescue => e
    @error = e.message
    false
  end

  def assemble
    if user.user_onboarding.nil?
      join_org_board
      @user_onboarding = onboarding.user_onboardings.build({ user: user })
    else
      @user_onboarding = user.user_onboarding
    end

    onboarding.save!
  end

  def onboarding_id
    onboarding.id
  end

  private

    def user
      @user ||= User.where({ email: email }).first_or_create do |u|
        u.name = name
        u.accepted_invitation_at = Time.now
        u.is_client_admin = true
      end
    end

    def join_org_board
      board = onboarding.board
      user.board_memberships.build({ demo: board, is_client_admin: true })
    end
end
