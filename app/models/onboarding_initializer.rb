class OnboardingInitializer
  attr_reader :email, :name, :organization_name, :user_onboarding, :reference_board_id, :error, :organization

  def initialize(params)
    @email = params[:email]
    @name = params[:name]
    @organization_name = params[:organization]
    @reference_board_id = params[:board_id]
    @user_onboarding = UserOnboarding.new({state: 1})
  end

  def save
    assemble
  rescue => e
    @error = e.message
    false
  end

  def is_valid?
    @organization_name.present? && @email.present? && @name.present?
  end

  def user
    @user ||= User.where({email:email}).first_or_initialize do |u|
      u.name = name
      u.accepted_invitation_at = Time.now
      u.organization = @organization
      u.is_client_admin = true
    end
  end

  def user_onboarding
    @user_onboarding
  end

  def topic_boards
    @topic_boards ||= TopicBoard.onboarding_board_set
  end

   def to_json
     {
       user_onboarding: user_onboarding.id,
       hash: user_onboarding.auth_hash,
       user: user.data_for_mixpanel.merge({time: DateTime.now })
     }
   end

  private

  def assemble
    @organization = Organization.where(name: organization_name).first_or_initialize
    if user.user_onboarding.nil?
      onboarding = @organization.onboarding || @organization.build_onboarding(topic_name: topic_name)
      @user_onboarding = onboarding.user_onboardings.build({
        onboarding: onboarding,
        user: user,
        state: 2
      })


      @board = onboarding.board || onboarding.build_board(reference_board.attributes.merge({name: copied_board_name, public_slug: copied_board_name}))

      @board.board_memberships.build({
        user: @user_onboarding.user,
        is_client_admin: true,
        is_current: true
      })

      if @board.tiles.empty?
        copy_tiles_to_new_board
      end
      @organization.save!
      @board.save!
    else
      @user_onboarding = user.user_onboarding
      @organization.save!
    end
  end

  def copy_tiles_to_new_board
    CopyBoard.new(@board, reference_board).copy_active_tiles_from_board
  end

  def reference_board
    @ref_board ||=Demo.includes(:tiles).find(@reference_board_id)
  end

  def copied_board_name
    organization_name + "-" + topic_name + "-" + @organization.boards.count.to_s
  end

  def topic_name
    reference_board.topic_board.topic_name
  end
end
