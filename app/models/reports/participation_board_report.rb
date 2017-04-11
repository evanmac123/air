class Reports::ParticipationBoardReport < Reports::BoardReport

  def attributes
    {
      users: eligible_users_count,
      logged_on: logged_on_percent,
      email_only: email_only_percent,
      tile_emails: tile_emails_count
    }
  end

  private
    def logged_on_percent
      if eligible_users_count > 0
        (logged_on_user_count.to_f / eligible_users_count).round(4)
      else
        0.00
      end
    end

    def email_only_percent
      (1 - logged_on_percent).round(4)
    end

    def eligible_users_count
      @eligible_user_count ||= board.users.non_site_admin.where("users.created_at < ?", to_date.end_of_year).count
    end

    def logged_on_user_count
      @logged_on_user_count ||= board.users.non_site_admin.where("accepted_invitation_at < ?", to_date.end_of_year).count
    end

    def tile_emails_count
      @tile_emails_count ||= board.tiles_digests.where("tiles_digests.created_at >= ? and tiles_digests.created_at <= ?", from_date, to_date).count
    end
end
