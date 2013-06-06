class TileBuilderForm
  extend  ActiveModel::Naming
  include ActiveModel::Conversion

  def initialize(demo, options = {})
    @demo = demo
    @parameters = options[:parameters]
    normalize_answers
  end

  def persisted?
    false
  end

  def create_objects
    build_tile
    build_rule
    build_answers

    if valid?
      Tile.transaction do
        main_objects.each {|object| object.save(:context => :client_admin)}
        associate_answers_with_rule
        make_primary_answer
        create_trigger
      end
    end
  end

  def tile
    unless @tile
      @tile = @demo.tiles.new
    end

    @tile
  end

  def rule
    unless @rule
      @rule = @demo.rules.new
    end

    @rule
  end

  def answers
    unless @answers
      @answers = [RuleValue.new]
    end

    @answers
  end

  def error_messages
    clean_error_messages
    errors_from_main_objects = main_objects.map{|object| object.errors.messages.values}.flatten
    (errors_from_main_objects + inherent_errors).join(", ") + "."
  end

  def valid?
    validities = main_objects.map{|object| object.valid?(:client_admin)}
    validities.all? && inherent_errors.empty?
  end

  protected

  def clean_error_messages
    if @tile.errors[:image]
      @tile.errors.delete(:thumbnail)
    end

    if @answers.first.value.blank?
      @answers.first.errors.delete(:value)
      @answers.first.errors[:value] = "must have at least one answer"
    end
  end

  def build_tile
    @tile = @demo.tiles.build

    if @parameters.present?
      @tile.image = @parameters[:image]
      @tile.thumbnail = @parameters[:image]
      @tile.headline = @parameters[:headline]
      @tile.supporting_content = @parameters[:supporting_content]
      @tile.question = @parameters[:question]
    end

    @tile.position = Tile.next_position(@demo)
    @tile.status = Tile::ACTIVE
  end

  def build_rule
    @rule = @demo.rules.build(alltime_limit: 1)

    if @parameters.present?
      rule.points = @parameters[:points]

      headline = @parameters[:headline]
      rule.reply = "+#{@parameters[:points]} points! Great job! You completed the \"#{headline}\" tile."
      rule.description = "Answered a question on the \"#{headline}\" tile."
    end
  end

  def build_answers
    @answers = []

    if @parameters.present?
      @parameters[:answers].each do |answer|
        @answers << RuleValue.new(value: answer)
      end
    end

    @answers = nil unless @answers.first.present?
  end

  def create_trigger
    Trigger::RuleTrigger.create(rule: rule, tile: tile)
  end

  def associate_answers_with_rule
    answers.each {|answer| answer.update_attributes(rule_id: rule.id)}
  end

  def make_primary_answer
    answers.first.update_attributes(is_primary: true)
  end

  def main_objects
    [tile, rule, answers].flatten
  end

  def inherent_errors
    result = []

    answers.map(&:value).select(&:present?).each do |value|
      if conflicting_value(value)
        result << "\"#{value}\" is already taken"
      end

      if value.length == 1
        result << "answer \"#{value}\" must have more than one letter"
      end
    end

    result
  end

  def conflicting_value(value)
    conflicts_with_demo_specific_rule(value) || 
    conflicts_with_standard_playbook_rule(value) ||
    conflicts_with_special_command(value)
  end

  def conflicts_with_demo_specific_rule(value)
    RuleValue.existing_value_within_demo(@demo, value).present?
  end

  def conflicts_with_standard_playbook_rule(value)
    return nil unless @demo.use_standard_playbook
    RuleValue.existing_value_within_demo(nil, value).present?
  end

  def conflicts_with_special_command(value)
    SpecialCommand.is_reserved_word?(value)
  end

  def normalize_answers
    if @parameters && @parameters[:answers]
      @parameters[:answers] = @parameters[:answers].map(&:strip).select(&:present?).map(&:downcase)
    end
  end

  delegate :headline, :supporting_content, :question, :to => :tile
  delegate :points, :to => :rule
end
