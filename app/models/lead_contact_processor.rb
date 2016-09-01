class LeadContactProcessor
  attr_reader :lead_contact, :user, :organization, :board, :board_template

  def self.dispatch(lead_contact, board_params)
    LeadContactProcessor.new(lead_contact, board_params).process
  end

  def initialize(lead_contact, board_params)
    @lead_contact = lead_contact
    @user = build_user
    @organization = user.organization
    @board = build_board(board_params)
    @board_template = find_template(board_params[:template_id])
  end

  def process
    user.save
    copy_tiles_to_new_board
    lead_contact.update_attributes(user_id: user.id)
  end

  private

    def build_user
      User.new(
        name: lead_contact.name,
        email: lead_contact.email,
        phone_number: lead_contact.phone,
        organization_id: lead_contact.organization_id
      )
    end

    def build_board(board_params)
      board = organization.boards.create(
        name: board_params[:name],
        logo: board_params[:logo].presence,
        custom_reply_email_name: board_params[:custom_reply_email_name],
        email: build_email(board_params[:name])
      )

      user.board_memberships.new(
        demo_id: board.id
      )

      board
    end

    def build_email(board_name)
      "#{board_name.gsub(/\W/,'')}@ourairbo.com"
    end

    def find_template(board_id)
      Demo.includes(:tiles).find(board_id)
    end

    def copy_tiles_to_new_board
      CopyBoard.new(board, board_template).copy_active_tiles_from_board
    end
end
