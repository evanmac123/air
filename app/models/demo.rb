class Demo < ActiveRecord::Base
  has_many :users
  has_many :acts, :through => :users
  has_many :rules
  has_many :surveys
  has_many :survey_questions, :through => :surveys

  # We go through this rigamarole since we can move a user from one demo to
  # another, and usually we will only be concerned with acts belonging to the
  # current demo. The :conditions option on has_many isn't quite flexible
  # enough to specify this.
  #
  # Meanwhile we have a corresponding before_create callback in Act to make
  # sure the demo_id there gets set appropriately.

  def acts_with_current_demo_checked
    self.acts_without_current_demo_checked.in_demo(self)
  end

  alias_method_chain :acts, :current_demo_checked

  def welcome_message(user)
    self.custom_welcome_message || "You've joined the #{self.company_name} game! Your unique ID is #{user.sms_slug} (text MYID if you forget). To play, text to this #. Text HELP for help."
  end

  def victory_achievement_message(user = nil)
    custom_message_about_user(
      :custom_victory_achievement_message,
      'default_victory_achievement_message',
      'You won on %{winning_time}. Congratulations!',
      user,
      :winning_time => [:won_at, :winning_time_format]
    )
  end

  def victory_sms(user = nil)
    custom_message_about_user(
      :custom_victory_sms,
      'default_victory_sms',
      "Congratulations! You've got %{points} points and have qualified for the drawing!",
      user,
      :points => [:points]
    )
  end

  def victory_scoreboard_message(user = nil)
    custom_message_about_user(
      :custom_victory_scoreboard_message,
      'default_victory_scoreboard_message',
      "Won game!",
      user
    )
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

  def has_rule_matching?(value)
    self.rules.where(:value => value).present?
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

  protected

  def custom_message_about_user(custom_message_method_name, default_message_key, default_default_message, user = nil, method_chains_for_interpolation = {})
    custom_message_text = self.send(custom_message_method_name)

    uninterpolated_text = if custom_message_text.blank?
      I18n.translate("activerecord.demo.#{default_message_key}", :default => default_default_message)
    else
      custom_message_text
    end

    if user
      interpolations = {}
      method_chains_for_interpolation.each do |key, method_chain|
        interpolations[key] = method_chain.inject(user) {|result, method_name| result.try(method_name)}
      end
      I18n.interpolate(uninterpolated_text, interpolations)
    else
      uninterpolated_text
    end
  end

end
