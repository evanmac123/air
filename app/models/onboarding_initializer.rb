class OnboardingInitializer
  attr_reader :email, :name, :organization_name, :user_onboarding, :reference_board_id, :error

  def initialize(params)
    @email = params[:email]
    @name = params[:name]
    @organization_name = params[:organization]
    @reference_board_id = params[:board_id]
  end

  def save
    begin
      #ActiveRecord::Base.transaction do
        initialize_onboarding
      #end
    rescue => e
      @error = e
      false
    end
  end

  def assemble
    org = Organization.where(name: organization_name).first_or_initialize
    onboarding = org.build_onboarding
    board = onboarding.build_board(reference_board.attributes.merge({name: copied_board_name, public_slug: copied_board_name})) #board
    user_onboarding = onboarding.user_onboardings.build({onboarding: onboarding, user: User.new({email:email, name: name, accepted_invitation_at: Time.now})})
    board.board_memberships.build({user: user_onboarding.user})
    org.save
  end

  def initialize_onboarding
    org = Organization.where(name: organization_name).first_or_create!
    user = org.users.where(email: email).first_or_create! do |u|
      u.name = name
      u.accepted_invitation_at = Time.now
    end

    copy_reference_board(org, user)

    onboarding = Onboarding.where(organization: org).first_or_create! do |o|
      o.demo_id = user.reload.demo_id
    end

    @user_onboarding = onboarding.user_onboardings.where(user: user).first_or_create!(user: user)
  end

  def user_onboarding_id
    @user_onboarding.id
  end

  def target_user

  end

  private

    def copy_reference_board(org, user)

      board_name = copied_board_name(org, reference_board)

      board = org.boards.where(name: board_name).first_or_create! do |b|
        b.email = user.email
      end

      user.board_memberships.where(demo_id: board.id).first_or_create! do |bm|
        bm.is_client_admin = true
      end

      if board.tiles.empty?
        copy_tiles_to_new_board(board, reference_board)
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
