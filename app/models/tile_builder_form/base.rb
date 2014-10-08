module TileBuilderForm
  class Base
    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    validate :main_objects_all_valid

    def self.model_name
      ActiveModel::Name.new(TileBuilderForm)
    end

    def initialize(demo, options = {})
      @demo = demo
      @parameters = options[:parameters]
      @tile = options[:tile]
      @creator = options[:creator]
      @image_container = options[:image_container]
    end

    def persisted?
      false
    end

    def build_objects
      build_tile
    end

    def create_objects
      build_objects
      save_objects if valid?
    end

    def update_objects
      update_tile
      before_validate_on_update_hook

      if valid?
        save_objects
        after_save_on_update_hook
        true
      end
    end

    def update_public_attributes
      if @parameters.present?
        @tile.attributes = {
          is_public:   @parameters[:is_public],
          is_copyable: @parameters[:is_copyable]
        }
      end
      set_tile_taggings

      if valid?
        save_objects
        after_save_on_update_hook
        true
      end
    end

    def tile
      @tile ||= tile_class.new(demo: @demo, is_copyable: true)
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

    def entered_answers
      @entered_answers ||= normalized_entered_answers
    end

    def tile_tag_ids
        @tile_tag_ids ||= (@parameters && @parameters[:tile_tag_ids] && @parameters[:tile_tag_ids]) || 
          (@tile && @tile.tile_taggings.map(&:tile_tag_id).join(',')) || ''
    end
    
    def tile_tags
      @tile_tags ||= begin
        tile_tag_ids = (@parameters && @parameters[:tile_tag_ids] && @parameters[:tile_tag_ids].split(',')) || 
          (@tile && @tile.tile_taggings.map(&:tile_tag_id)) || []
        TileTag.where(id: tile_tag_ids)
      end
    end
        
    def error_messages
      clean_error_messages
      errors.values.join(", ") + "."
    end

    def answer_prompt
      "Give the answers and mark the correct one. If survey, do not mark any."
    end

    protected

    def tile_class
      OldSchoolTile
    end

    def save_objects
      tile_class.transaction do
        save_main_objects
        after_save_main_objects_hook
        true
      end
    end

    def save_main_objects      
      main_objects.each {|object| object.save(:context => :client_admin)}
    end

    def after_save_main_objects_hook
    end

    def before_validate_on_update_hook
    end

    def after_save_on_update_hook
    end

    def clean_error_messages
      remove_thumbnail_error
    end

    def build_tile
      @tile = tile_class.new(demo: @demo)
      set_tile_image
      set_tile_attributes
      set_tile_creator
      #set_tile_taggings
      @tile.status = Tile::DRAFT
    end

    def update_tile
      set_tile_image
      set_tile_attributes
      #set_tile_taggings
    end

    def remove_extraneous_rule_values
      extraneous_rule_values = rule.rule_values.reject{|answer| answers.include? answer.value}
      extraneous_rule_values.each(&:destroy)
    end

    def set_tile_taggings
      if @parameters[:tile_tag_ids].present?
        tile_tag_ids = @parameters[:tile_tag_ids].split(',').map(&:to_i)
 
        new_tile_tag_ids = tile_tag_ids
        
        if @tile.persisted?
          existing_tile_tag_ids = @tile.tile_taggings.map(&:tile_tag_id)
          new_tile_tag_ids = tile_tag_ids - existing_tile_tag_ids                    
        end
        
        #only keep the new and non-removed tile taggings
        associated_tile_taggings = @tile.tile_taggings.where(tile_tag_id: tile_tag_ids)
        new_tile_tag_ids.each do |tile_tag_id|
          associated_tile_taggings << @tile.tile_taggings.build(tile_tag_id: tile_tag_id)
        end
        @tile.tile_taggings = associated_tile_taggings
      else 
        @tile.tile_taggings = []
      end      
    end
    
    def set_tile_image
      if @parameters[:image].present?
        @tile.image = @tile.thumbnail = @parameters[:image]
      elsif @image_container == "no_image"
        @tile.image = @tile.thumbnail = nil
      elsif @image_container.to_i > 0
        @tile.image = @tile.thumbnail = ImageContainer.find(@image_container).image
      end
    end

    def set_tile_attributes
      if @parameters.present?
        @tile.attributes = {
          headline:           @parameters[:headline],
          supporting_content: @parameters[:supporting_content],
          question:           @parameters[:question],
          link_address:       @parameters[:link_address],
          question_type:      @parameters[:question_type],
          question_subtype:   @parameters[:question_subtype],
          image_credit:       @parameters[:image_credit].try(:strip)#,
          #is_public:          @parameters[:is_public],
          #is_copyable:        @parameters[:is_copyable]
        }

      end
    end

    def set_tile_creator
      @tile.creator ||= @creator
    end

    def main_objects
      [tile, rule, rule_values].flatten
    end

    def errors_from_main_objects
      main_objects.map{|object| object.errors.messages.values}.flatten
    end

    def normalized_answers
      [normalized_answers_from_params, normalized_answers_from_tile, blank_answers].detect {|answer_source| answer_source.present?}
    end

    def normalized_entered_answers
      [normalized_answers_from_params, blank_answers].detect {|answer_source| answer_source.present?}
    end

    def normalized_answers_from_params
      return unless answers_from_params
      answers_from_params.map{|answer| answer.strip}.select(&:present?).uniq
    end

    def answers_from_params
      return unless @parameters && @parameters[:answers]
      @parameters[:answers]
    end

    def normalized_answers_from_tile
      return unless @tile && @tile.persisted?
      @tile.first_rule.rule_values.pluck(:value)
    end

    def blank_answers
      [''] * default_answer_count
    end

    def default_answer_count
      1
    end

    def main_objects_all_valid
      #tile_taggings
      invalid_objects = main_objects.reject{|object| object.valid?(:client_admin)}

      clean_error_messages


      invalid_objects.each do |invalid_object|
        invalid_object.errors.values.each {|error| errors.add :base, error}
      end
      check_quiz_on_correct_answer if errors.empty?
    end

    def check_quiz_on_correct_answer
      if tile.question_type == "Quiz" && \
        (tile.correct_answer_index.nil? || tile.correct_answer_index < 0)
        errors.add :base, "For a quiz, you have to have to mark a correct answer. Click an answer in your tile to mark the correct answer"
      end
    end

    def remove_thumbnail_error
      tile.errors.delete(:thumbnail)
    end

    delegate :headline, :supporting_content, :question, :question_type, :question_subtype, :thumbnail, :image, :image_credit, :link_address, :to => :tile
    def is_copyable
      tile.is_copyable?
    end
  
    def is_public
      tile.is_public?
    end

    def is_sharable
      tile.is_sharable?
    end
    
    delegate :points, :to => :rule
  end
end
