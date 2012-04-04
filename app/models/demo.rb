class Demo < ActiveRecord::Base
  has_many :users, :dependent => :destroy
  has_many :acts
  has_many :rules, :dependent => :destroy
  has_many :rule_values, :through => :rules
  has_many :surveys, :dependent => :destroy
  has_many :survey_questions, :through => :surveys
  has_many :bonus_thresholds, :dependent => :destroy
  has_many :levels, :dependent => :destroy
  has_many :goals, :dependent => :destroy
  has_many :bad_words, :dependent => :destroy
  has_many :suggested_tasks, :dependent => :destroy
  has_many :self_inviting_domains, :dependent => :destroy
  has_many :locations, :dependent => :destroy
  has_many :characteristics, :dependent => :destroy

  has_one :skin

  validate :end_after_beginning

  has_alphabetical_column :name

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

  def welcome_message(user=nil)
    custom_message(
      :custom_welcome_message,
      "You've joined the %{name} game! @{reply here}",
      user,
      :name => [:demo, :name],
      :unique_id    => [:sms_slug]
    )
  end

  def victory_achievement_message(user = nil)
    custom_message(
      :custom_victory_achievement_message,
      'You won on %{winning_time}. Congratulations!',
      user,
      :winning_time => [:won_at, :pretty]
    )
  end

  def victory_sms(user = nil)
    custom_message(
      :custom_victory_sms,
      "Congratulations! You've got %{points} points and have qualified for the drawing!",
      user,
      :points => [:points]
    )
  end

  def victory_scoreboard_message(user = nil)
    custom_message(
      :custom_victory_scoreboard_message,
      "Won game!",
      user
    )
  end

  def prize_message(user = nil)
    custom_message(
      :prize,
      "Sorry, no physical prizes this time. This one's just for the joy of the contest."
    )
  end

  def help_response(user = nil)
    custom_message(
      :help_message,
      "Text:\nRULES for command list\nPRIZES for prizes\nSUPPORT for help from the help desk"
    )
  end

  def game_not_yet_begun_response
    custom_message(
      :act_too_early_message,
      "The game will begin #{self.begins_at.pretty}. Please try again after that time."      
    )
  end

  def game_over_response
    custom_message(
      :act_too_late_message,
      "Thanks for playing! The game is now over. If you'd like more information e-mailed to you, please text MORE INFO."
    )
  end

  def game_not_yet_begun?
    self.begins_at && Time.now < self.begins_at
  end

  def game_over?
    self.ends_at && Time.now > self.ends_at
  end

  def game_open?
    !game_not_yet_begun? && !game_over?
  end

  def game_closed?
    !game_open?
  end

  # This is meant to be called by a cron job just after midnight, to update
  # this demo's users' recent moving average scores and related rankings.

  def recalculate_all_moving_averages!
    return
    Demo.transaction do
      self.users.claimed.each do |user|
        user.recalculate_moving_average!
      end

      self.fix_recent_average_user_rankings!
    end
  end

  def fix_user_rankings!(points_column, ranking_column)
    ordered_users = self.users.claimed.order("#{points_column} DESC")
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
    #Demo.transaction do
      #unless_within(10.minutes.ago, total_user_rankings_last_updated_at) {fix_user_rankings!('points', 'ranking')}
    #end
  end

  def fix_recent_average_user_rankings!
    #Demo.transaction do
      #unless_within(10.minutes.ago, average_user_rankings_last_updated_at) {fix_user_rankings!('recent_average_points', 'recent_average_ranking')}
    #end
  end

  def has_rule_value_matching?(value)
    self.rule_values.where(:value => value).present?
  end

  def set_level_indices
    self.levels.order(:threshold).each_with_index do |level, index|
      # SQL rather than update_attribute since we're calling this
      # indirectly from an after_save callback on Level, leading to an
      # infinite loop if we trigger callbacks yet again.
      #
      # Also, index + 2, since if a user hasn't completed any levels they're
      # effectively "level 1". So the 0th member of this list is "level 2".
      #
      # TODO: after Rails upgrade, replace that grotty piece of SQL with
      # update_column
      
      Level.connection.execute("UPDATE levels SET index_within_demo = #{index + 2} WHERE levels.id = #{level.id}")
      #level.update_column(:index_within_demo, index + 2)
    end
  end

  def self.recalculate_all_moving_averages!
    Demo.all.each do |demo|
      begin
        demo.recalculate_all_moving_averages!
      rescue StandardError => e
        Airbrake.notify(e)
      end
    end
  end

  def schedule_blast_sms(text, send_time)
    delay(:run_at => send_time).send_blast_sms(text)
  end

  def send_blast_sms(text)
    users.with_phone_number.each {|user| OutgoingMessage.send_message(user, text)}
  end

  def number_not_found_response
    custom_message(
      :unrecognized_user_message,
      self.class.default_number_not_found_response
    )
  end

  def detect_bad_words(attempted_value)
    words = attempted_value.split
    BadWord.reachable_from_demo(self).including_any_word(words).limit(1).present?
  end

  def location_breakdown
    {}.tap do |breakdown|
      self.locations.each {|location| breakdown[location] = location.users.count}
    end
  end

  def self.number_not_found_response(receiving_number)
    demo = self.where(:phone_number => receiving_number).first
    demo ? demo.number_not_found_response : default_number_not_found_response
  end

  def self.default_number_not_found_response
    "I can't find your number in my records. Did you claim your account yet? If not, text your first initial and last name (if you are John Smith, text \"jsmith\")."
  end

  protected

  def unless_within(cutoff_time, last_done_time)
    if last_done_time.nil? || cutoff_time >= last_done_time
      Demo.transaction do
        yield
      end
    end
  end

  def custom_message(custom_message_method_name, default_message, user = nil, method_chains_for_interpolation = {})
    custom_message_text = self.send(custom_message_method_name)

    semi_interpolated_text = if custom_message_text.blank?
      default_message
    else
      custom_message_text
    end

    if user
      interpolations = {}
      method_chains_for_interpolation.each do |key, method_chain|
        interpolations[key] = method_chain.inject(user) {|result, method_name| result.try(method_name)}
      end
      I18n.interpolate(semi_interpolated_text, interpolations)
    else
      semi_interpolated_text
    end
  end

  def end_after_beginning
    if begins_at && ends_at && ends_at <= begins_at
      errors.add(:begins_at, "must come before the ending time")
    end
  end
end
