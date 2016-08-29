class LeadContactProcessor
  attr_reader :user, :board, :board_template

  def self.dispatch(lead_contact, board_params)
    LeadContactProcessor.new(lead_contact, board_params).process
  end

  def initialize(lead_contact, board_params)
    @user = build_user(lead_contact)
    @board = build_board(board_params)
    @board_template = find_template(board_params[:template_id])
  end

  def process
    binding.pry
    copy_tiles_to_new_board
  end

  private

    def build_user(lead_contact)
      User.new(
        name: lead_contact.name,
        email: lead_contact.email,
        phone_number: lead_contact.phone,
        organization_id: lead_contact.organization_id
      )
    end

    def build_board(board_params)
      user.demos.new(
        name: board_params[:name],
        logo: board_params[:logo].presence
      )
    end

    def find_template(board_id)
      Demo.includes(:tiles).find(board_id)
    end

    def copy_tiles_to_new_board
      CopyTile.new(board, user).copy_active_tiles_from_demo(board_template)
    end
end
