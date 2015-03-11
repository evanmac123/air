class TileBuilderForm
  extend  ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  validate :main_objects_all_valid

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

  def create_tile
    build_tile
    save_tile if valid?
  end

  def update_tile
    set_tile_image
    set_tile_attributes

    if valid?
      save_tile
      true
    end
  end

  def tile
    @tile ||= MultipleChoiceTile.new(demo: @demo, is_copyable: true)
  end

  def error_messages
    clean_error_messages
    errors.values.join(", ") + "."
  end

  def self.model_name
    ActiveModel::Name.new(TileBuilderForm)
  end

  protected

  def save_tile
    Tile.transaction { tile.save(context: :client_admin) }
  end

  def clean_error_messages
    remove_thumbnail_error
  end

  def build_tile
    @tile = MultipleChoiceTile.new(demo: @demo)
    set_tile_image
    set_tile_attributes
    set_tile_creator
    @tile.status = Tile::DRAFT
    @tile.position = @tile.find_new_first_position
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

  def set_tile_creator
    @tile.creator ||= @creator
  end

  def errors_from_tile
    tile.errors.messages.values
  end

  def main_objects_all_valid
    tile_valid = tile.valid?(:client_admin)
    clean_error_messages

    unless tile_valid
      tile.errors.values.each {|error| errors.add :base, error}
    end

    check_quiz_on_correct_answer if errors.empty?
  end

  def check_quiz_on_correct_answer
    if tile.question_type == "Quiz" &&
      (tile.correct_answer_index.nil? || 
       tile.correct_answer_index < 0)

      quiz_error_mess = "For a quiz, you have to have to mark a correct answer." +
                        " Click an answer in your tile to mark the correct answer"
      errors.add :base, quiz_error_mess
    end
  end

  def remove_thumbnail_error
    tile.errors.delete(:thumbnail)
  end

  def set_tile_attributes
    if @parameters.present?
      @tile.attributes = {
        headline:                @parameters[:headline],
        supporting_content:      @parameters[:supporting_content],
        question:                @parameters[:question],
        link_address:            @parameters[:link_address],
        question_type:           @parameters[:question_type],
        question_subtype:        @parameters[:question_subtype],
        image_credit:            @parameters[:image_credit].try(:strip),
        points:                  @parameters[:points].to_i,
        correct_answer_index:    normalized_correct_answer_index,
        multiple_choice_answers: normalized_answers,
      }
    end
  end

  def normalized_correct_answer_index
    answers_normalizer.normalized_correct_answer_index
  end

  def normalized_answers
    answers_normalizer.normalized_answers
  end

  def answers_normalizer
    @answers_builder ||= AnswersNormalizer.new(
      @parameters[:answers], 
      @parameters[:correct_answer_index]
    )
  end

  delegate  :headline, 
            :supporting_content, 
            :question, 
            :question_type, 
            :question_subtype, 
            :thumbnail, 
            :image, 
            :image_credit, 
            :link_address, 
            :points, 
            :to => :tile
end
