# frozen_string_literal: true

class DisplayCategorizedTiles
  def self.displayable_categorized_tiles(user, maximum_tiles, current_board = nil)
    demo = current_board || user.demo
    result = satisfiable_tiles_categorized_to_user(user, demo, maximum_tiles)

    return result unless maximum_tiles

    length_not_completed = result[:not_completed_tiles].length
    length_completed = result[:completed_tiles].length

    if length_not_completed > maximum_tiles
      result[:not_completed_tiles] = result[:not_completed_tiles].first(maximum_tiles)
      result[:completed_tiles] = nil
    elsif (length_not_completed + length_completed) > maximum_tiles
      result[:completed_tiles] = result[:completed_tiles].first(maximum_tiles - length_not_completed)
    else
      result[:all_tiles_displayed] = true
    end
    result
  end

  private

    def self.satisfiable_tiles_categorized_to_user(user, demo, maximum_tiles)
      {
        completed_tiles:      all_completed_tiles(user, demo).order("tile_completions.id DESC").limit(maximum_tiles + 1).to_a,
        not_completed_tiles:  not_completed_tiles(user, demo).limit(maximum_tiles + 1).to_a,
        all_tiles_displayed:  false
      }
    end

    def self.tiles_due_in_demo(user, demo)
      demo.tiles.active.segmented_for_user(user)
    end

    def self.all_completed_tiles(user, demo)
      demo.tiles.joins(:tile_completions).where(tile_completions: { user_id: user.id, user_type: user.class.to_s })
    end

    def self.not_completed_tiles(user, demo)
      tiles_due_in_demo(user, demo).where.not(id: all_completed_tiles(user, demo).select(:id)).order(position: :desc)
    end
end
