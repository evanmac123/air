class Report::CleanedActivity < Report::Activity
  def initialize(game_specificer)
    @_user_cache = {}
    super
  end

  def data_for_act(act)
    user_points, user_top_level = find_user_data(act)

    date = act.created_at.strftime("%Y-%m-%d")
    hour = act.created_at.strftime("%H")
    minute = act.created_at.strftime("%M")
    [date, hour, minute, act.user_id, cleaned_text(act), act.points, act.referring_user_id, user_points, user_top_level]
  end

  protected

  def header_line
    CSV.generate_line(["Date", "Hour", "Minute", "User ID", "Text", "Points", "Referring user ID", "User points", "User level"])
  end

  def cleaned_text(act)
    case act.text
    when /^got credit for referring .+ to the game$/
      "got credit for referring someone to the game"
    when /^credited .+ for referring them to the game$/
      "credited someone for referring them to the game"
    when /^is now friends with .+$/
      "is now friends with someone"
    when /^told .+ about a command$/
      "told someone about a command"
    when /^(.+) \(thanks (.+) for the referral\)$/
      $1
    else
      act.text
    end
  end

  def find_user_data(act)
    if (user_data = @_user_cache[act.user_id]).present?
      user_data
    else
      user = act.user
      user_data = [user.points, user.top_level_index]
      @_user_cache[act.user_id] = user_data
      user_data
    end
  end
end
