class TileUserTargeter
  def initialize(tile:, rule:)
    @_tile = tile
    @_rule = rule
  end

  def get_users
    if rule[:scope] == :answered
      users_who_answered(answer_idx: rule[:answer_idx])
    elsif rule[:scope] == :did_not_answer
      users_who_did_not_answer(answer_idx: rule[:answer_idx])
    end
  end

  def users_who_answered(answer_idx: nil)
    if answer_idx.present?
      users_who_answered_specific_answer(answer_idx: answer_idx)
    else
      targetable_users.joins(:tile_completions).where(tile_completions: { tile_id: tile_id } )
    end
  end

  def users_who_did_not_answer(answer_idx: nil)
    if answer_idx.present?
      users_who_chose_different_answer(answer_idx: answer_idx)
    else
      targetable_users.where("users.id NOT IN (?)", users_who_answered.pluck(:id))
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
      tile.tiles_digest
    end

    def tile_id
      tile.id
    end

    def targetable_users
      tile.demo.users
    end

    def users_who_answered_specific_answer(answer_idx:)
      targetable_users.joins(:tile_completions).where(tile_completions: { tile_id: tile.id, answer_index: answer_idx } )
    end

    def users_who_chose_different_answer(answer_idx:)
      targetable_users.joins(:tile_completions).where('"tile_completions"."tile_id" = ? AND "tile_completions"."answer_index" != ?', tile.id, answer_idx)
    end

    #NOT USED: Here if we want to include users who did not answer at all in the did_not_answer_x scope.
    def users_who_did_not_answer_specific_answer(answer:)
      targetable_users.where("users.id IN (?) OR users.id IN (?)", users_who_did_not_answer, users_who_chose_different_answer(answer: answer))
    end
end
