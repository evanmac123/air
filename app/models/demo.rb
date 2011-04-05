class Demo < ActiveRecord::Base
  has_many :users
  has_many :acts, :through => :users

  def welcome_message(user)
    self.custom_welcome_message || "You've joined the #{self.company_name} game! Your unique ID is #{user.sms_slug} (text MYID for a reminder). To play, send texts to this #. Send a text HELP for help."
  end

  def game_over?
    self.ends_at && Time.now >= self.ends_at
  end

  # This is meant to be called by a cron job just after midnight, to update
  # this demo's users' recent moving average scores and related rankings.

  def recalculate_all_moving_averages!
    Demo.transaction do
      self.users.each do |user|
        user.recalculate_moving_average!
      end

      ordered_users = self.users.order('recent_average_points DESC')
      ordered_users.each_with_index do |user, i|
        user.recent_average_ranking = if i == 0
                                        1
                                      else
                                        previous_user = ordered_users[i - 1]
                                        if user.recent_average_points == previous_user.recent_average_points
                                          previous_user.recent_average_ranking
                                        else
                                          i + 1
                                        end
                                      end

        User.update_all({:recent_average_ranking => user.recent_average_ranking}, {:id => user.id})
      end
    end
  end

  def self.alphabetical
    order("company_name asc")
  end
end
