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
    update_board_name(board)
    if @organization.save
      setup_sales_org
    end

    self
  end

  def valid?
    organization.persisted?
  end

  private

    def setup_sales_org
      copy_tiles_to_board(board)
      link_board_and_user(user, board)
      creator.move_to_new_demo(board)
      add_sales_role_to_org
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

    def update_board_name(board)
      if board.name.empty?
        board.name = @organization.name
      end
    end

    def link_board_and_user(user, board)
      user.board_memberships.create(demo: board)
    end

    def copy_tiles_to_board(board)
      unless copy_board.nil? || copy_board.empty?
        CopyBoard.new(board, Demo.find(copy_board)).copy_active_tiles_from_board
      end
    end

    def default_sales_board
      Demo.find_by_name("HR Bulletin Board").try(:id)
    end
end
