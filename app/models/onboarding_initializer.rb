class OnboardingInitializer
  attr_reader :email, :name, :organization_name, :user_onboarding, :reference_board_id, :error

  def initialize(params)
    @email = params[:email]
    @name = params[:name]
    @organization_name = params[:organization]
    @reference_board_id = params[:board_id]
    @uob= UserOnboarding.new({state: 1})
  end

  def save
    assemble
    @organization.save!
  rescue => e
    @error = e
    false
  end

  def user
    @user ||= User.where({email:email}).first_or_initialize do |u|
      u.name = name
      u.accepted_invitation_at = Time.now 
    end
  end

  def state
    user_onboarding.present? ? user_onboarding.state : 1
  end

  def has_active_user_onboarding?
    user_onboarding.persisted?
  end

  def has_no_active_user_onboarding?
    not has_active_user_onboarding?
  end

  def user_onboarding
    @uob ||= user.user_onboarding
  end

  def user_onboarding_id
    has_active_user_onboarding? ? user_onboarding.id : nil
  end

  def topic_boards
    @topic_boards ||= TopicBoard.reference_board_set
  end

  private

  def validate_user
    user.include(:organization).persisted? 
  end

  def assemble

    if user.user_onboarding.nil?
      @organization = Organization.where(name: organization_name).first_or_initialize
      onboarding = @organization.onboarding || @organization.build_onboarding
      board = onboarding.board || onboarding.build_board(reference_board.attributes.merge({name: copied_board_name, public_slug: copied_board_name})) #board

      @user_onboarding = user.user_onboarding || onboarding.user_onboardings.build({
        onboarding: onboarding, 
        user: user,
        state: 1
      })

      board.board_memberships.build({user: @user_onboarding.user, is_client_admin: true})
    end
  end



  def copy_tiles_to_new_board(new_board, reference_board)
    CopyBoard.new(new_board, reference_board).copy_active_tiles_from_board
  end

  def reference_board
    @ref_board ||=Demo.includes(:tiles).find(@reference_board_id)
  end

  def copied_board_name
    organization_name + "-" + topic_name
  end

  def topic_name
    reference_board.topic_board.topic.name
  end
end
