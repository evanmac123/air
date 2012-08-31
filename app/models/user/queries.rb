module User::Queries
  def with_some_gold_coins
    where("gold_coins > 0")
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
    users = User.where("LOWER(#{attribute}) like ?", "%" + text + "%").where(:demo_id => demo.id )
    users = users.where('users.id != ?', user_to_exempt.id) if user_to_exempt
    users
  end
  
  def get_claimed_users_where_like(text, demo, attribute)
    get_users_where_like(text, demo, attribute).claimed
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
end
