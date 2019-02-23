# frozen_string_literal: true

class DisplayCategorizedTiles
  def self.displayable_categorized_tiles(user:, maximum_tiles:, current_board: nil, page: { incomplete_tiles_page: 1, complete_tiles_page: 1 }, offset: 0)
    demo = current_board || user.demo
    result = satisfiable_tiles_categorized_to_user(user, demo, maximum_tiles, page, offset)

    return result unless maximum_tiles

    length_not_completed = result[:not_completed_tiles].length
    length_completed = result[:completed_tiles].length

    if length_not_completed > maximum_tiles
      result[:not_completed_tiles] = result[:not_completed_tiles].first(maximum_tiles)
      result[:incomplete_tiles_page] = result[:incomplete_tiles_page] + 1
      result[:completed_tiles] = nil
    elsif (length_not_completed + length_completed) > maximum_tiles
      offset = maximum_tiles - length_not_completed
      result[:completed_tiles] = result[:completed_tiles].first(maximum_tiles - length_not_completed)
      result[:offset] = offset
      result[:incomplete_tiles_page] = 0
      result[:complete_tiles_page] = result[:complete_tiles_page] + 1
    else
      result[:incomplete_tiles_page] = 0
      result[:complete_tiles_page] = 0
      result[:all_tiles_displayed] = true
    end
    result
  end

  private

    def self.satisfiable_tiles_categorized_to_user(user, demo, maximum_tiles, page, offset)
      not_completed = page[:incomplete_tiles_page] == 0 ? [] : not_completed_tiles(user, demo).page(page[:incomplete_tiles_page]).per(maximum_tiles + 1).to_a
      completed = not_completed.length > maximum_tiles ? [] : completed_tiles(user, demo, maximum_tiles, page, offset)
      {
        not_completed_tiles:   not_completed,
        completed_tiles:       completed,
        complete_tiles_page:   page[:complete_tiles_page],
        incomplete_tiles_page: page[:incomplete_tiles_page],
        offset:                0,
        all_tiles_displayed:   false
      }
    end

    def self.tiles_due_in_demo(user, demo)
      if demo.population_segments.length > 0
        demo.tiles.active.segmented_for_user(user)
      else
        demo.tiles.active
      end
    end

    def self.all_completed_tiles(user, demo)
      user ? demo.tiles.joins(:tile_completions).where(tile_completions: { user_id: user.id, user_type: user.class.to_s }) : []
    end

    def self.not_completed_tiles(user, demo)
      tiles_due_in_demo(user, demo).where.not(id: all_completed_tiles(user, demo).select(:id)).order(position: :desc)
    end

    def self.completed_tiles(user, demo, maximum_tiles, page, offset)
      page = page[:complete_tiles_page] > 0 ? page[:complete_tiles_page] : 1
      all_completed_tiles(user, demo).order("tile_completions.id DESC").page(page).per(maximum_tiles + 1).padding(offset).to_a
    end
end
