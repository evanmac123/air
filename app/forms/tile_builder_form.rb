class TileBuilderForm
  extend  ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include Rails.application.routes.url_helpers

  attr_accessor :tile

  validate :main_objects_all_valid

  def initialize(demo, options = {})
    @demo = demo
    @parameters = (options[:parameters] || {})
    @tile = (options[:tile] || MultipleChoiceTile.new(demo: @demo))
    @creator = options[:creator]
  end

  def create_tile
    build_tile
    delete_old_image_container
    save_tile if valid?
  end

  def update_tile
    set_tile_image
    set_tile_attributes
    delete_old_image_container
    save_tile if valid?
  end

  def image_container
    image_builder.find_image_container
  end

  def old_image_container
    image_container
  end

  def image_url
    (image_builder.find_image || image).url
  end

  def no_image
    @parameters[:no_image] == "true"
  end

  def image_from_library
    image_builder.find_image_from_library_id
  end

  def create_url
    client_admin_tiles_path
  end

  def update_url
    client_admin_tile_path tile
  end

  def url
    if tile.new_record?
      create_url
    else
      update_url
    end
  end

  def form_params
    params = {url: url}
    params.merge!({method: :put}) unless tile.new_record?
    params
  end

  def submit_button_text
    tile.new_record? ? "Save tile" : "Update tile"
  end

  def return_button_text
    tile.new_record? ? "Back" : "Cancel"
  end

  def error_messages
    errors.values.join(", ") + "."
  end

  def error_message
    "Sorry, we couldn't save this tile: " + error_messages
  end

  def self.model_name
    ActiveModel::Name.new(TileBuilderForm)
  end

  def persisted?
    false
  end

  protected

  def save_tile
     tile.save(context: :client_admin)
  end

  def build_tile
    #set_tile_image
    set_tile_attributes
    set_tile_creator
    tile.status = newly_built_tile_status
  end
  
  def set_tile_image
    new_image = image_builder.set_tile_image
    if new_image == :image_from_library
      tile_image = image_builder.find_image_from_library
      tile.image = tile_image.image
      tile.thumbnail = tile_image.thumbnail
    elsif new_image != :leave_old
      tile.image = tile.thumbnail = new_image 
    end
  end

  def set_tile_creator
    tile.creator ||= @creator
  end

  def set_tile_attributes
    if @parameters.present?
      tile.attributes = {
        headline:                @parameters[:headline],
        supporting_content:      sanitized_supporting_content,
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

  def delete_old_image_container
    image_builder.delete_old_image_container(valid?)
  end

  def image_builder
    @image_builder ||= ImageBuilder.new(
      @parameters[:image],
      @parameters[:image_container],
      @parameters[:old_image_container],
      no_image,
      @parameters[:image_from_library]
    )
  end

  def sanitized_supporting_content
    Sanitize.fragment(
      @parameters[:supporting_content].strip, 
      elements: [
        'ul', 'ol', 'li',               # lists
        'b', 'strong', 'i', 'em', 'u',  # text style
        'span', 'div', 'p',             # blocks
        'br', 'a'
      ],
      attributes: { 'a' => ['href', 'target'] }
    ).strip
  end
  #
  # => Answers Stuff
  #
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
  #
  # => Errors and Validations
  #
  def main_objects_all_valid
    tile_validation = TileValidation.new(tile)
    return if tile_validation.valid?
    
    tile_validation.errors_values.each do |error| 
      errors.add :base, error
    end
  end

  def newly_built_tile_status
    Tile::DRAFT  
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
