class User
  module Ranking
    def set_ranking(points_column, ranking_column)
      User.transaction do
        new_point_value = self[points_column]
        self[ranking_column] = self.demo.users.where("#{points_column} > ?", new_point_value).count + 1
        old_point_value = self.changed_attributes[points_column]

        User.update_all("#{ranking_column} = #{ranking_column} + 1", :id => lower_ranked_user_ids(points_column, new_point_value, old_point_value))
      end
    end

    def set_alltime_rankings
      set_ranking('points', 'ranking')
    end

    def set_recent_average_rankings
      set_ranking('recent_average_points', 'recent_average_ranking')
    end

    def lower_ranked_user_ids(points_column, new_point_value, old_point_value)
      # Remember, we haven't saved the new point value yet, so if self isn't a
      # new record (hence already has a database ID), we need to specifically
      # exempt it from this update.

      if self.id
        where_conditions = ["#{points_column} < ? AND #{points_column} >= ? AND id != ?", new_point_value, old_point_value, self.id]
      else
        where_conditions = ["#{points_column} < ? AND #{points_column} >= ?", new_point_value, old_point_value]
      end

      # The lock mitigates, but doesn't totally prevent, deadlocks. Until I think
      # of a better algorithm, or we can get Postgres to lock the fucking rows
      # in a consistent fucking order, we're done here.
      #
      # However, we're not calling set_ranking that much anymore (that is, no
      # longer on every single points update) so deadlocks may not be as much
      # of a problem.
      #
      # tl;dr: Life is hard. Bring me a drink.

      self.demo.users.where(where_conditions).order(:id).select("id").lock("FOR UPDATE").map(&:id)
    end

    def schedule_update_demo_alltime_rankings
      self.demo.delay.fix_total_user_rankings!
    end

    def schedule_update_demo_recent_average_rankings
      self.demo.delay.fix_recent_average_user_rankings!
    end
  end
end
