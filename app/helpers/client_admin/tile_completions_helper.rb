module ClientAdmin::TileCompletionsHelper
  def display_time_ago_and_date(dt)
    content_tag(:span, "#{time_ago_in_words(dt)} ago", class: 'has-tip', 
        title: dt.strftime(Wice::Defaults::DATE_FORMAT), data: {tooltip: ''})
  end
end