# frozen_string_literal: true

class ActFinder
  def self.call(viewing_user:, page:, per_page:)
    act_displayer = ActFinder.new(user: viewing_user, page: page, per_page: per_page)

    act_displayer.display
  end

  attr_reader :user, :board, :page, :per_page

  def initialize(user:, page:, per_page:)
    @user = user
    @board = user.demo
    @page = page
    @per_page = per_page
  end

  def display
    if only_display_own_acts?
      display_own_acts
    elsif user.is_client_admin || user.is_site_admin
      display_all_board_acts
    else
      display_friends_acts
    end
  end

  def only_display_own_acts?
    user.is_guest? || user.is_potential_user? || board.hide_social
  end

  def display_own_acts
    user.acts.where(demo: board).order(id: :desc).page(page).per(per_page)
  end

  def display_all_board_acts
    board.acts.order(id: :desc).page(page).per(per_page)
  end

  def display_friends_acts
    board.acts.user_acts.unhidden
      .where("(user_id=? OR user_id in (?) OR privacy_level='everybody')", user.id, user.displayable_accepted_friends.select(:id))
      .order(id: :desc)
      .page(page)
      .per(per_page)
  end
end
