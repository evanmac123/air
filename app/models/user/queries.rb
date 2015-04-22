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

  def wants_email
    where(:notification_method => %w(email both))
  end

  def wants_sms
    where(:notification_method => %w(sms both))
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

  def by_employee_or_spouse_code(code)
    case code.downcase
    when 'e'
      where(is_employee: true)
    when 's'
      where(is_employee: false)
    end
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

  def push_message_recipients(respect_notification_method, user_ids)
    users = User.where(:id => user_ids)

    if respect_notification_method
      email_recipient_ids = users.wants_email.pluck(:id)
      sms_recipient_ids = users.wants_sms.with_phone_number.pluck(:id)
    else
      email_recipient_ids = sms_recipient_ids = user_ids
    end

    return email_recipient_ids, sms_recipient_ids
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
