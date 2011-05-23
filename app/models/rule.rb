class Rule < ActiveRecord::Base
  belongs_to :demo

  has_many   :acts

  validates_presence_of   :value
  validates_uniqueness_of :value, :scope => :demo_id

  before_save :normalize_value

  def to_s
    description || value
  end

  def user_hit_limit?(user)
    return false unless self.alltime_limit

    self.acts.where(:user_id => user.id).count >= self.alltime_limit
  end

  def self.positive(limit)
    where("points > 0").limit(limit)
  end

  def self.negative(limit)
    where("points < 0").limit(limit)
  end

  def self.neutral(limit)
    where("points = 0").limit(limit)
  end

  def self.partially_matching_value(value)
    query_string = Rule.connection.quote_string(value.gsub(/\s+/, '|'))
    self.select("*, ts_rank(to_tsvector('english', value), query) AS rank").from("rules, to_tsquery('#{query_string}') query").where("suggestible = true AND to_tsvector('english', value) @@ query")
  end

  def self.in_same_demo_as(other)
    where("rules.demo_id IS NULL or (rules.demo_id = ?)",  other.demo_id)
  end

  def self.alphabetical
    order(:value)
  end

  protected

  def normalize_value
    self.value = self.value.strip.downcase.gsub(/\s+/, ' ')
  end

  def self.find_and_record_rule_suggestion(attempted_value, user)
    matches = self.in_same_demo_as(user).partially_matching_value(attempted_value).limit(3).order('rank DESC, lower(value)')

    begin
      result = "I didn't quite get what you meant. Maybe try #{suggestion_phrase(matches)}? Or text S to suggest we add what you sent."
      matches.pop if result.length > 160
    end while (matches.present? && result.length > 160) 

    return nil if matches.empty?

    user.last_suggested_items = matches.map(&:id).map(&:to_s).join('|')
    user.save!

    result
  end

  def self.suggestion_phrase(matches)
    # Why is there no #map_with_index? Srsly.

    match_index = 1
    match_strings = matches.map do |match| 
      substring = "(#{match_index}) \"#{match.value}\""
      match_index += 1
      substring
    end

    match_strings.join(' or ')
  end
end
