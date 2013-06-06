class RuleValue < ActiveRecord::Base
  belongs_to :rule
  has_one :demo, :through => :rule
  has_many :acts

  validates_presence_of :value

  validate :value_is_not_single_letter
  validate :at_most_one_primary_rule_value_per_rule
  validate :validate_value_unique_within_demo

  before_save :normalize_value

  has_alphabetical_column "rule_values.value"

  def normalize_value
    self.value = self.value.strip.downcase.gsub(/\s+/, ' ')
  end

  def self.partially_matching_value(value)
    normalized_value = value.gsub(/[^[:alnum:][:space:]]/, '').strip
    query_string = Rule.connection.quote_string(normalized_value.gsub(/\s+/, '|'))
    self.select("rule_values.*, ts_rank(to_tsvector('english', value), query) AS rank").from("to_tsquery('#{query_string}') query, rule_values").where("suggestible = true AND is_primary = true AND to_tsvector('english', value) @@ query")
  end

  def self.visible_from_demo(demo_or_associated)
    demo = demo_or_associated.kind_of?(Demo) ? demo_or_associated : demo_or_associated.demo

    where_clause = "(rules.demo_id = ?)"
    if demo.use_standard_playbook
      where_clause += " OR rules.demo_id IS NULL"
    end

    select('rule_values.*').joins('LEFT JOIN rules ON rules.id = rule_values.rule_id').where(where_clause, demo.id)
  end

  def self.oldest
    order('created_at ASC').limit(1)
  end

  def self.primary
    where(:is_primary => true)
  end

  protected

  def at_most_one_primary_rule_value_per_rule
    if self.is_primary 
      if (other = self.rule.rule_values.where(:is_primary => true).first) && (other != self)
        self.errors.add(:base, "Can't add a second primary value to a rule (has primary value: #{other.value})")
      end
    end
  end

  def validate_value_unique_within_demo
    other = self.class.existing_value_within_demo(self.rule.try(:demo), value)
    if other && other != self
      self.errors.add(:value, "must be unique within its demo")
    end
  end

  def value_is_not_single_letter
    return unless self.value =~ /^[[:alpha:]]$/
    self.errors.add(:value, "Can't have a single-letter value, those are reserved for other purposes.")
  end

  def self.existing_value_within_demo(demo, value)
    others = self.joins('INNER JOIN rules ON rules.id = rule_values.rule_id').where(:value => value)

    others = if demo
               others.where("rules.demo_id = ?", demo)
             else
               others.where('rules.demo_id IS NULL')
             end

    others.first
  end

  def self.suggestion_for(attempted_value, user)
    matches = RuleValue.suggestible_for(attempted_value, user)

    begin
      result = I18n.t(
        'activerecord.models.rule_value.suggestion_sms',
        :default => "I didn't quite get what \"#{attempted_value}\" means. @{Say} %{suggestion_phrase}, or \"s\" to suggest we add it.",
        :suggestion_phrase => suggestion_phrase(matches)
      )
      matches.pop if result.length > 160
    end while (matches.present? && result.length > 160) 
    length_limit = 80 # Restrict our response length
    if matches.empty?
      result = I18n.t(
        'activerecord.models.act.parse.no_suggestion_sms',
        :default => "Sorry, I don't understand what \"#{attempted_value[0..length_limit]}\" means. @{Say} \"s\" to suggest we add it."
      )

      return [result, nil]
    end

    last_suggested_item_ids = matches.map(&:id).map(&:to_s).join('|')  
 
    [result, last_suggested_item_ids]
  end

  def self.suggestible_for(attempted_value, user)
    self.visible_from_demo(user).partially_matching_value(attempted_value).where("rule_id IS NOT NULL").limit(3).order('rank DESC, lower(value)')  
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
