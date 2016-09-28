class UserOnboardingInitializer
  attr_reader :onboarding, :new_onboardings, :root_user
  def initialize(root_user_onboarding, new_onboardings)
    @root_user = root_user_onboarding.user
    @onboarding = root_user_onboarding.onboarding
    @new_onboardings = new_onboardings
  end

  def save
    org = onboarding.organization

    new_onboardings.each do |_key, user_onboarding|
      if user_onboarding[:email] && user_onboarding[:name]
        user = org.users.where(email: user_onboarding[:email]).first_or_create do |u|
          u.name = user_onboarding[:name]
          u.accepted_invitation_at = Time.now
        end

        if user.persisted?
          join_org_board(org, user)
          @user_onboarding = onboarding.user_onboardings.where(user: user).first_or_create!(user: user)

          OnboardingShareNotifier.delay_mail(user, @user_onboarding, root_user)
        end
      end
    end
  end

  def join_org_board(org, user)
    board = org.onboarding.board
    user.board_memberships.where(demo_id: board.id).first_or_create! do |bm|
      bm.is_client_admin = true
    end
  end
end
