class OnboardingInitializer
  attr_reader :email, :name, :organization_name, :reference_board_id, :error

  def initialize(params)
    @email = params[:email]
    @name = params[:name]
    @organization_name = params[:organization]
    @reference_board_id = params[:board_id]
  end

  def save
    begin
      ActiveRecord::Base.transaction do
        initialize_onboarding
      end
    rescue => e
      @error = e
      false
    end
  end

  def initialize_onboarding
    org = Organization.where(name: organization_name).first_or_create!
    onboarding = Onboarding.first_or_create!(organization: org)

    user = org.users.where(email: email).first_or_create! do |u|
      u.update_attributes!(name: name)
    end

    copy_reference_board(org, user)
    @user_onboarding = onboarding.user_onboardings.create!(user: user)
  end

  def user_onboarding_id
    @user_onboarding.id
  end

  private

    def copy_reference_board(org, user)
      reference_board = find_reference_board(reference_board_id)

      new_board = org.boards.create!(
        name: org.name,
        email: user.email
      )

      user.board_memberships.create!(
        demo_id: new_board.id,
        is_client_admin: true
      )

      copy_tiles_to_new_board(new_board, reference_board)
    end

    def copy_tiles_to_new_board(new_board, reference_board)
      CopyBoard.new(new_board, reference_board).copy_active_tiles_from_board
    end

    def find_reference_board(board_id)
      Demo.includes(:tiles).find(board_id)
    end
end
