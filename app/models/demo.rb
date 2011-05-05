class Demo < ActiveRecord::Base
  has_many :users
  has_many :acts, :through => :users
  has_many :rules

  # We go through this rigamarole since we can move a user from one demo to
  # another, and usually we will only be concerned with acts belonging to the
  # current demo. The :conditions option on has_many isn't quite flexible
  # enough to specify this.
  #
  # Meanwhile we have a corresponding before_create callback in Act to make
  # sure the demo_id there gets set appropriately.

  def acts_with_current_demo_checked
    self.acts_without_current_demo_checked.where(:demo_id => self.id)
  end

  alias_method_chain :acts, :current_demo_checked

  def welcome_message(user)
    self.custom_welcome_message || "You've joined the #{self.company_name} game! Your unique ID is #{user.sms_slug} (text MYID if you forget). To play, text to this #. Text HELP for help."
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

      self.fix_recent_average_user_rankings!
    end
  end

  def fix_user_rankings!(points_column, ranking_column)
    ordered_users = self.users.ranked.order("#{points_column} DESC")
    ordered_users.each_with_index do |user, i|
      user[ranking_column] = if i == 0
                                      1
                                    else
                                      previous_user = ordered_users[i - 1]
                                      if user[points_column] == previous_user[points_column]
                                        previous_user[ranking_column]
                                      else
                                        i + 1
                                      end
                                    end

      User.update_all({ranking_column => user[ranking_column]}, {:id => user.id})
    end
  end

  def fix_total_user_rankings!
    fix_user_rankings!('points', 'ranking')
  end

  def fix_recent_average_user_rankings!
    fix_user_rankings!('recent_average_points', 'recent_average_ranking')
  end

  def self.recalculate_all_moving_averages!
    Demo.all.each do |demo|
      begin
        demo.recalculate_all_moving_averages!
      rescue StandardError => e
        HoptoadNotifier.notify(e)
      end
    end
  end

  def self.alphabetical
    order("company_name asc")
  end
end
