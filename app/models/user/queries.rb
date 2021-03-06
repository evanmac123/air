module User::Queries
  def with_some_tickets
    where("users.tickets > 0")
  end

  def in_canonical_ranking_order
    order("points DESC, name ASC")
  end

  def with_phone_number
    where("phone_number IS NOT NULL AND phone_number != ''")
  end

  def name_starts_with(start)
    where("name ILIKE ?", start.like_escape + "%")
  end

  def name_starts_with_non_alpha
    where("name !~* '^[[:alpha:]]'")
  end

  def name_like(text)
    where("name ILIKE ?", "%" + text + "%")
  end

  def by_claim_code(claim_code)
    where(claim_code: claim_code)
  end

  def by_zip_code(zip_code)
    where(zip_code: zip_code)
  end

  def claimed
    where("accepted_invitation_at IS NOT NULL")
  end

  def unclaimed
    where(:accepted_invitation_at => nil)
  end

  def claimed_on_board_membership(demo_id, excluded_uids=[])
    user_arel = User.arel_table

    joins(:board_memberships).where(board_memberships: { demo_id: demo_id }).where("board_memberships.joined_board_at IS NOT NULL").where(user_arel[:id].not_in(excluded_uids))
  end

  def unclaimed_on_board_membership(demo_id)
    joins(:board_memberships).where(board_memberships: { demo_id: demo_id }).where(board_memberships: { joined_board_at: nil })
  end

  def get_users_where_like(text, demo, attribute, user_to_exempt = nil)
    users = demo.users.where("#{attribute} ILIKE ?", "%" + text + "%")
    users = users.where('users.id != ?', user_to_exempt.id) if user_to_exempt
    users
  end

  def get_claimed_users_where_like(text, demo, attribute)
    get_users_where_like(text, demo, attribute).claimed
  end

  def search_for_users text, demo, limit = nil, user_to_exempt = nil
    names  = get_users_where_like(text, demo, "name", user_to_exempt)
    slugs  = get_users_where_like(text, demo, "slug", user_to_exempt)

    names = names.limit(limit)
    slugs = slugs.limit(limit)

    matched_users = names
    slugs.each do |s|
      matched_users << s unless matched_users.include? s
    end

    matched_users[0, limit]
  end

  def by_date_of_birth_string(dob_string)
    month_part = dob_string[0..1].to_i
    day_part = dob_string[2..3].to_i

    where("EXTRACT(MONTH FROM date_of_birth) = ? AND EXTRACT(DAY FROM date_of_birth) = ?", month_part, day_part)
  end

  def by_employee_id(employee_id)
    where(employee_id: employee_id)
  end

  def with_game_referrer
    where("game_referrer_id IS NOT NULL")
  end

  def demo_mates(current_user)
    user_ids = BoardMembership.where(demo_id: current_user.demo_ids).pluck(:user_id)
    where(id: user_ids).where('users.id != ?', current_user.id)
  end

  def push_message_recipients(user_ids:, demo_id:, respect_notification_method:)
    if respect_notification_method
      email_recipient_ids = User.wants_email(user_ids: user_ids, demo_id: demo_id).pluck(:id)
      sms_recipient_ids = User.wants_sms(user_ids: user_ids, demo_id: demo_id).with_phone_number.pluck(:id)
    else
      email_recipient_ids = sms_recipient_ids = user_ids
    end

    return email_recipient_ids, sms_recipient_ids
  end

  def users_with_bm_notification_pref(user_ids, demo_id)
    User.select("users.id, board_memberships.notification_pref_cd AS notification_pref_cd").joins(:board_memberships).where(id: user_ids, board_memberships: { demo_id: demo_id })
  end

  def wants_email(user_ids:, demo_id:)
    users_with_bm_notification_pref(user_ids, demo_id).where("notification_pref_cd = ? OR notification_pref_cd = ?", BoardMembership.notification_prefs[:email], BoardMembership.notification_prefs[:both])
  end

  def wants_sms(user_ids:, demo_id:)
    users_with_bm_notification_pref(user_ids, demo_id).where("notification_pref_cd = ? OR notification_pref_cd = ?", BoardMembership.notification_prefs[:text_message], BoardMembership.notification_prefs[:both])
  end

  def alphabetical_by_name
    order("name")
  end

  def updated_since(baseline_time)
    where("users.updated_at > ?", baseline_time)
  end

  def not_updated_since(baseline_time)
    where("users.updated_at <= ?", baseline_time)
  end
end
