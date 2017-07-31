class TileUserTargeter
  def initialize(tile:, rule:)
    @_tile = tile
    @_rule = rule
  end

  def get_users
    if rule[:scope] == :answered
      users_who_answered(answer: rule[:answer])
    elsif rule[:scope] == :did_not_answer
      users_who_did_not_answer(answer: rule[:answer])
    end
  end

  def users_who_answered(answer: nil)
    if answer.present?
      users_who_answered_specific_answer(answer: answer)
    else
      targetable_users.joins(:tile_completions).where(tile_completions: { tile_id: tile_id } )
    end
  end

  def users_who_did_not_answer(answer: nil)
    if answer.present?
      users_who_chose_different_answer(answer: answer)
    else
      targetable_users.where("users.id NOT IN (?)", users_who_answered)
    end
  end

  private

    def tile
      @_tile
    end

    def rule
      @_rule
    end

    def tiles_digest
      @_tiles_digest ||= tile.tiles_digest
    end

    def tile_id
      tile.id
    end

    def user_select_clause
      User.select([:id, :name, :email]).joins(:board_memberships)
    end

    def targetable_users_claimed_only
      user_select_clause.where("board_memberships.demo_id = ? AND board_memberships.joined_board_at <= ?", tile.demo_id, tile.activated_at)
    end

    def targetable_users_all
      user_select_clause.where("board_memberships.demo_id = ? AND board_memberships.created_at <= ?", tile.demo_id, tile.activated_at)
    end

    def targetable_users
      if tiles_digest && !tiles_digest.include_unclaimed_users
        targetable_users_claimed_only
      else
        targetable_users_all
      end
    end

    def users_who_answered_specific_answer(answer:)
      answer_idx = tile.multiple_choice_answers.index(answer)

      targetable_users.joins(:tile_completions).where(tile_completions: { tile_id: tile.id, answer_index: answer_idx } )
    end

    def users_who_chose_different_answer(answer:)
      answer_idx = tile.multiple_choice_answers.index(answer)

      targetable_users.joins(:tile_completions).where('"tile_completions"."tile_id" = ? AND "tile_completions"."answer_index" != ?', tile.id, answer_idx)
    end

    #NOT USED: Here if we want to include users who did not answer at all in the did_not_answer_x scope.
    def users_who_did_not_answer_specific_answer(answer:)
      targetable_users.where("users.id IN (?) OR users.id IN (?)", users_who_did_not_answer, users_who_chose_different_answer(answer: answer))
    end
end
