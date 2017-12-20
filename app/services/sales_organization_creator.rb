class SalesOrganizationCreator
  attr_reader :creator, :organization, :user, :board, :copy_board

  def initialize(creator, copy_board = nil, org_params = {})
    @creator = creator
    @organization = Organization.new(org_params)
    @user = get_user
    @board = get_board
    @copy_board = copy_board
  end

  def create!
    update_board_name_and_email(board)
    set_sales_defaults
    if @organization.save
      link_board_and_user(user, board)
      setup_sales_org
    end

    self
  end

  def valid?
    organization.persisted?
  end

  private

    def set_sales_defaults
      board.guest_user_conversion_modal = false
      organization.email = user.email
    end

    def setup_sales_org
      creator.move_to_new_demo(board)
      add_sales_role_to_org
      copy_tiles_to_board(board)
    end

    def add_sales_role_to_org
      creator.add_role(:sales, organization)
    end

    def get_board
      organization.boards.first || organization.boards.build
    end

    def get_user
      organization.users.first || organization.users.build
    end

    def update_board_name_and_email(board)
      if board.name.empty?
        board.name = @organization.name
      end

      board.email = board.name.parameterize + "@ourairbo.com"
    end

    def link_board_and_user(user, board)
      user.board_memberships.create(demo: board)
    end

    def copy_tiles_to_board(board)
      if copy_board.present?
        BoardCopier.new(board, Demo.find(copy_board)).delay.copy_active_tiles_from_board
      end
    end
end
