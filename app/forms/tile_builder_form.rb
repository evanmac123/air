class TileBuilderForm
  #TODO remove Deprecated methods and move others to private if not being called
  #from outside
  extend  ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include Rails.application.routes.url_helpers

  attr_accessor :tile

  validate :main_objects_all_valid

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
            :position,
            :remote_media_url,
            :remote_media_type,
            :to => :tile

  def initialize(demo, options = {})
    @demo = demo
    @action = options[:action]
    @form_params = (options[:form_params] || {})
    @tile = (options[:tile] || MultipleChoiceTile.new(demo: @demo, position: demo.next_draft_tile_position))
    @creator = options[:creator]

    @exclude_attrs = [:supporting_content, :correct_answer_index,
                      :multiple_choice_answers, :image_container,
                      :old_image_container, :no_image, :image_from_library, :answers]
  end

  def create_tile
    build_tile
    delete_old_image_container
    save_tile
  end

  def update_tile
    set_tile_attributes
    delete_old_image_container
    save_tile
  end

  def image_container
    image_builder.find_image_container
  end

  def old_image_container
    image_container
  end

  def image_url
    (image_builder.find_image || image).url ||  remote_media_url
  end

  def no_image
    @form_params[:no_image] == "true"
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

  def has_question_type?
    @action == "edit" || @action == "update" || ( @action == "create" && question_type.present?)
  end

  def question_config
    { hasQuestionType: has_question_type?, type: question_type, subType: question_subtype}
  end

  protected

  def save_tile
    if tile.save(context: :client_admin)
      process_thumbail
      return true
    else
      false
    end
  end

  def build_tile
    set_tile_attributes
    set_tile_creator
    tile.status = newly_built_tile_status
  end

  def process_thumbail
    ImageProcessJob.new(tile.id).perform if image_changed?
  end


  def set_tile_creator
    tile.creator ||= @creator
  end

  def set_tile_attributes
    if @form_params.present?
      @tile.assign_attributes filtered_tile_attributes
    end
  end

  def delete_old_image_container
    image_builder.delete_old_image_container(valid?)
  end

  def image_builder
    @image_builder ||= ImageBuilder.new(
      @form_params[:image],
      @form_params[:image_container],
      @form_params[:old_image_container],
      no_image,
      @form_params[:image_from_library]
    )
  end

  def sanitized_supporting_content
    Sanitize.fragment(
      @form_params[:supporting_content].strip,
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
      @form_params[:answers],
      @form_params[:correct_answer_index]
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


  private

  def filtered_tile_attributes
    @form_params.except(*@exclude_attrs).merge({
      supporting_content:      sanitized_supporting_content,
      correct_answer_index:    normalized_correct_answer_index,
      multiple_choice_answers: normalized_answers,
    }).merge(image_processing_attributes)
  end

  def set_tile_image
    # TODO Deprecated
    new_image = image_builder.set_tile_image
    if new_image == :image_from_library
      tile_image = image_builder.find_image_from_library
      tile.image = tile_image.image
      tile.thumbnail = tile_image.thumbnail
    elsif new_image != :leave_old
      tile.image = tile.thumbnail = new_image
    end
  end

  def image_changed?
    @tile_image_changed ||= @form_params[:remote_media_url].present? && ((@tile.new_record? ) || (@form_params[:remote_media_url] != @tile.remote_media_url))
  end

  def image_processing_attributes
    #forces delayed paperclip to think the tile is being processed before the
    #attachment is actually assigned in the background job
    image_changed? ? {thumbnail_processing: true, image_processing: true} : {}
  end

end
