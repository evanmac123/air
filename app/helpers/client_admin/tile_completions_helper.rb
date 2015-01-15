module ClientAdmin::TileCompletionsHelper
  def display_time_ago_and_date(dt)
    content_tag(:span, "#{time_ago_in_words(dt)} ago", class: 'has-tip', 
        title: dt.strftime(Wice::Defaults::DATE_FORMAT), data: {tooltip: ''})
  end
  def dispay_short_and_full_answer(answer)
  	content_tag(:span, answer[0...15], class: 'has-tip', 
        title: answer, data: {tooltip: ''})
  end

  def tile_completions_csv_link(tile)
  	params = {
  		tc_grid: {
  			export: "csv"
  		}
  	}
  	client_admin_tile_tile_completions_path(tile) + "?#{params.to_query}"
  end

  def non_completions_csv_link tile
  	params = {
  		nc_grid: {
  			export: "csv"
  		}
  	}
  	client_admin_tile_tile_completions_path(tile) + "?#{params.to_query}"
  end

  def joined_field user
    if user.claimed?
      '<span class="joined">Yes</span>'.html_safe
    else
      '<span class="not-joined">No</span>'.html_safe
    end
  end
end