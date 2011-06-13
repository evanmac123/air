class RuleValue < ActiveRecord::Base
  belongs_to :rule
  has_one :demo, :through => :rule

  validates_presence_of :value, :rule_id

  validate :value_has_more_than_one_character
  validate :at_most_one_primary_rule_value_per_rule
  validate :value_unique_within_demo

  before_save :normalize_value

  def normalize_value
    self.value = self.value.strip.downcase.gsub(/\s+/, ' ')
  end


  def self.partially_matching_value(value)
    normalized_value = value.gsub(/[^[:alnum:][:space:]]/, '')
    query_string = Rule.connection.quote_string(normalized_value.gsub(/\s+/, '|'))
    self.select("rule_values.*, ts_rank(to_tsvector('english', value), query) AS rank").from("to_tsquery('#{query_string}') query, rule_values").where("suggestible = true AND is_primary = true AND to_tsvector('english', value) @@ query")
  end

  def self.in_same_demo_as(other)
    select('rule_values.*').joins('INNER JOIN rules ON rules.id = rule_values.rule_id').where("rules.demo_id IS NULL or (rules.demo_id = ?)",  other.demo_id)
  end

  def self.oldest
    order('created_at ASC').limit(1)
  end

  def self.with_value_in(value_array)
    # This may be the silliest code I write all year. But it works fine.
    # TODO: I was seriously sleep-deprived when I wrote this. There's a
    # saner way to do it.
    mess_of_question_marks = "?," * value_array.length
    where_string = "value IN (#{mess_of_question_marks}"
    where_string[-1] = ')'

    where([where_string, *value_array])
  end

  def self.alphabetical
    order('rule_values.value ASC')
  end

  protected

  def at_most_one_primary_rule_value_per_rule
    if self.is_primary 
      if (other = self.rule.rule_values.where(:is_primary => true).first) && (other != self)
        self.errors.add(:base, "Can't add a second primary value to a rule (has primary value: #{other.value})")
      end
    end
  end

  def value_unique_within_demo
    other = self.class.joins('INNER JOIN rules ON rules.id = rule_values.rule_id').where(:value => self.value)

    other = if self.rule.demo
              other.where(["rules.demo_id = ?", self.rule.demo.id])
            else
              other.where('rules.demo_id IS NULL')
            end

    if other.first && other.first != self
      self.errors.add(:value, "Value must be unique within its demo")
    end
  end

  def value_has_more_than_one_character
    if self.value.try(:length) == 1
      self.errors.add(:value, "Can't have a single-character value, those are reserved for other purposes.")
    end
  end

  def self.find_and_record_rule_suggestion(attempted_value, user)
    matches = self.in_same_demo_as(user).partially_matching_value(attempted_value).limit(3).order('rank DESC, lower(value)')

    begin
      result = I18n.t(
        'activerecord.models.rule_value.suggestion_sms',
        :default => "I didn't quite get that. Text %{suggestion_phrase}, or \"s\" to suggest we add what you sent.",
        :suggestion_phrase => suggestion_phrase(matches)
      )
      matches.pop if result.length > 160
    end while (matches.present? && result.length > 160) 

    return nil if matches.empty?

    user.last_suggested_items = matches.map(&:id).map(&:to_s).join('|')
    user.save!

    result
  end

  def self.suggestion_phrase(matches)
    # Why is there no #map_with_index? Srsly.

    alphabet = ('a'..'z').to_a
    match_index = 0
    match_strings = matches.map do |match| 
      letter = alphabet[match_index]
      substring = "\"#{letter}\" for \"#{match.value}\""
      match_index += 1
      substring
    end

    match_strings.join(', ')
  end
end
