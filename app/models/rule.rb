class Rule < ActiveRecord::Base
  has_many   :acts

  validates_presence_of   :value
  validates_uniqueness_of :value

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

  protected

  def normalize_value
    self.value = self.value.strip.downcase.gsub(/\s+/, ' ')
  end

  def self.find_rule_suggestion(attempted_value)
    matches = self.partially_matching_value(attempted_value).limit(3).order('rank DESC, lower(value)')
    return nil if matches.empty?

    matches.map{|match| "\"#{match.value}\""}.join(' or ')
  end
end
