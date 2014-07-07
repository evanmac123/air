class RemoveUserFromBoard
  def initialize(user, board_or_board_id)
    @user = user
    @board_id = board_or_board_id
    @board_id = @board_id.id if board_or_board_id.kind_of?(Demo)
  end

  def remove!
    return unless can_leave_board?

    BoardMembership.transaction do
      if board_membership_to_leave.is_current?
        move_user_to_another_board
      end

      board_membership_to_leave.delete
    end
  end

  protected

  def move_user_to_another_board
    if most_recently_posted_board
      @user.move_to_new_demo(most_recently_posted_board)
    else
      @user.move_to_new_demo(possible_boards_to_move_into.first)
    end
  end

  def can_leave_board?
    board_isnt_paid? && not_last_board?
  end

  def board_isnt_paid?
    !(board_membership_to_leave.demo.is_paid)
  end

  def not_last_board?
    board_memberships.limit(2).length > 1
  end

  def board_memberships
    @board_memberships ||= @user.board_memberships
  end

  def board_membership_to_leave
    @board_membership_to_leave ||= board_memberships.find_by_demo_id(@board_id)
  end

  def most_recently_posted_board
    @most_recently_posted_board ||= possible_boards_to_move_into.most_recently_posted_to.first.try(:demo)  
  end

  def possible_boards_to_move_into
    @possible_boards_to_move_into ||= board_memberships.uncurrent
  end
end
