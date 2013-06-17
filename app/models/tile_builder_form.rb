class TileBuilderForm
  extend  ActiveModel::Naming
  include ActiveModel::Conversion

  def initialize(demo, options = {})
    @demo = demo
    @parameters = options[:parameters]
    @tile = options[:tile]
  end

  def persisted?
    false
  end

  def create_objects
    build_tile
    build_rule
    build_rule_values

    save_objects if valid?
  end

  def update_objects
    update_tile
    update_rule
    update_rule_values

    if valid?
      save_objects
      remove_extraneous_rule_values
    end
  end

  def tile
    @tile ||= @demo.tiles.new
  end

  def rule
    @rule ||= tile.persisted? ? tile.first_rule : @demo.rules.new
  end

  def rule_values
    @rule_values ||= tile.persisted? ? tile.first_rule.rule_values : [RuleValue.new]
  end

  def answers
    @answers ||= normalized_answers
  end

  def error_messages
    clean_error_messages
    (errors_from_main_objects + inherent_errors).join(", ") + "."
  end

  def valid?
    validities = main_objects.map{|object| object.valid?(:client_admin)}
    validities.all? && inherent_errors.empty?
  end

  protected

  def save_objects
    Tile.transaction do
      save_main_objects
      associate_rule_values_with_rule
      create_trigger
    end
  end

  def save_main_objects
    main_objects.each {|object| object.save(:context => :client_admin)}
  end

  def clean_error_messages
    remove_thumbnail_error
    change_blank_answer_error if no_rule_values_given
  end

  def remove_thumbnail_error
    @tile.errors.delete(:thumbnail)
  end

  def no_rule_values_given
    # Due to the normalization we do on answers, if there are any non-blank
    # answers at all, there must be a non-blank answer in the first slot.
    @rule_values.first.value.blank?
  end

  def change_blank_answer_error
    @rule_values.first.errors.delete(:value)
    @rule_values.first.errors[:value] = "must have at least one answer"
  end

  def build_tile
    @tile = @demo.tiles.build
    set_tile_image
    set_tile_attributes
    @tile.position = Tile.next_position(@demo)
    @tile.status = Tile::ACTIVE
  end

  def update_tile
    set_tile_attributes
  end

  def update_rule
    set_rule_attributes
  end

  def update_rule_values
    @rule_values = []
    answers.each do |answer|
      existing_value = rule.rule_values.find_by_value(answer)
      if existing_value
        @rule_values << existing_value
      else
        @rule_values << rule.rule_values.build(value: answer)
      end
    end
  end

  def remove_extraneous_rule_values
    extraneous_rule_values = rule.rule_values.reject{|answer| answers.include? answer.value}
    extraneous_rule_values.each(&:destroy)
  end

  def set_tile_image
    if @parameters.present?
      @tile.image = @tile.thumbnail = @parameters[:image]
    end
  end

  def set_tile_attributes
    if @parameters.present?
      @tile.attributes = {
        headline:           @parameters[:headline],
        supporting_content: @parameters[:supporting_content],
        question:           @parameters[:question]
      }
    end
  end

  def build_rule
    @rule = @demo.rules.build(alltime_limit: 1)
    set_rule_attributes
  end

  def set_rule_attributes
    if @parameters.present?
      rule.points = @parameters[:points]

      headline = @parameters[:headline]
      rule.reply = "+#{@parameters[:points]} points! Great job! You completed the \"#{headline}\" tile."
      rule.description = "Answered a question on the \"#{headline}\" tile."
    end
  end

  def build_rule_values
    @rule_values = []

    if @parameters.present?
      answers.each do |answer|
        @rule_values << RuleValue.new(value: answer)
      end
    end

    @rule_values = nil unless @rule_values.first.present?
  end

  def create_trigger
    Trigger::RuleTrigger.create(rule: rule, tile: tile)
  end

  def associate_rule_values_with_rule
    rule_values.each {|answer| answer.update_attributes(rule_id: rule.id)}
  end

  def main_objects
    [tile, rule, rule_values].flatten
  end

  def errors_from_main_objects
    main_objects.map{|object| object.errors.messages.values}.flatten
  end

  def inherent_errors
    result = []

    rule_values.map(&:value).select(&:present?).each do |value|
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

  def normalized_answers
    [normalized_answers_from_params, normalized_answers_from_tile, ['']].detect {|answer_source| answer_source.present?}
  end

  def normalized_answers_from_params
    return unless @parameters && @parameters[:answers]
    @parameters[:answers].map{|answer| answer.strip.downcase}.select(&:present?).uniq
  end

  def normalized_answers_from_tile
    return unless @tile && @tile.persisted?
    @tile.first_rule.rule_values.pluck(:value)
  end

  delegate :headline, :supporting_content, :question, :thumbnail, :to => :tile
  delegate :points, :to => :rule
end
