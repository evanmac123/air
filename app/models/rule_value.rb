class RuleValue < ActiveRecord::Base
  belongs_to :rule
  has_one :demo, :through => :rule

  validates_presence_of :value

  validate :value_has_more_than_one_character
  validate :at_most_one_primary_rule_value_per_rule
  validate :value_unique_within_demo

  before_save :normalize_value

  def normalize_value
    self.value = self.value.strip.downcase.gsub(/\s+/, ' ')
  end

  def forbidden?
    self.rule_id.nil?
  end

  def not_forbidden?
    !self.forbidden?
  end

  def self.partially_matching_value(value)
    normalized_value = value.gsub(/[^[:alnum:][:space:]]/, '').strip
    query_string = Rule.connection.quote_string(normalized_value.gsub(/\s+/, '|'))
    self.select("rule_values.*, ts_rank(to_tsvector('english', value), query) AS rank").from("to_tsquery('#{query_string}') query, rule_values").where("suggestible = true AND is_primary = true AND to_tsvector('english', value) @@ query")
  end

  def self.visible_from_demo(other)
    where_clause = "(rules.demo_id = ?)"
    if other.demo.use_standard_playbook
      where_clause += " OR rules.demo_id IS NULL"
    end

    select('rule_values.*').joins('LEFT JOIN rules ON rules.id = rule_values.rule_id').where(where_clause, other.demo_id)
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

  def self.forbidden
    where(:rule_id => nil)
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

    other = if self.rule.try(:demo)
              other.where(["rules.demo_id = ?", self.rule.demo.id])
            else
              other.where('rules.demo_id IS NULL')
            end

    if other.first && other.first != self
      self.errors.add(:value, "must be unique within its demo")
    end
  end

  def value_has_more_than_one_character
    if self.value.try(:length) == 1
      self.errors.add(:value, "Can't have a single-character value, those are reserved for other purposes.")
    end
  end

  def self.suggestible_for(attempted_value, user)
    self.visible_from_demo(user).partially_matching_value(attempted_value).where("rule_id IS NOT NULL").limit(3).order('rank DESC, lower(value)')  
  end
end
