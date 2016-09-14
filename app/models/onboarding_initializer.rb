class OnboardingInitializer
  attr_reader :email, :name, :organization_name

  def initialize(params)
    @email = params[:email]
    @name = params[:name]
    @organization_name = params[:organization]
  end

  def save
    begin
      ActiveRecord::Base.transaction do
        initialize_onboarding
      end
    rescue
      false
    end
  end

  def initialize_onboarding
    org = Organization.where(name: organization_name).first_or_create!
    onboarding = Onboarding.first_or_create!(organization: org)

    user = org.users.where(email: email).first_or_create! do |u|
      u.update_attributes(name: name)
    end

    @user_onboarding = onboarding.user_onboardings.create!(user: user)
  end

  def user_onboarding_id
    @user_onboarding.id
  end
end
