class TilePublicForm
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :tile, :parameters
  validate :main_objects_all_valid

  def initialize(tile, parameters = {})
    @tile = tile
    @parameters = parameters
    @is_public_initial = is_public
  end

  def save
    set_tile_public_params
    set_tile_taggings
    save_tile if valid?
  end

  def tile_tags
    @tile_tags ||= begin
      tile_tag_ids = (@parameters && @parameters[:tile_tag_ids] && @parameters[:tile_tag_ids].split(',')) || 
        (@tile && @tile.tile_taggings.map(&:tile_tag_id)) || []
      TileTag.where(id: tile_tag_ids)
    end
  end

  def is_copyable
    tile.is_copyable?
  end

  def is_public
    tile.is_public?
  end

  def self.model_name
    ActiveModel::Name.new(TilePublicForm)
  end

  def persisted?
    false
  end

  protected

  def tile_became_public
    is_public && !@is_public_initial
  end

  def save_tile
    Tile.transaction do 
      if tile.save(context: :client_admin) && tile_became_public
        Tile.reorder_explore_page_tiles!([tile.id]) 
      end
    end
  end

  def set_tile_public_params
    if parameters[:is_public].present? && parameters[:is_copyable].present?
      tile.attributes = {
        is_public:   parameters[:is_public],
        is_copyable: parameters[:is_copyable]
      }
    end
  end

  def tile_tag_ids
    @tile_tag_ids ||= (@parameters && @parameters[:tile_tag_ids] && @parameters[:tile_tag_ids]) || 
      (@tile && @tile.tile_taggings.map(&:tile_tag_id).join(',')) || ''
  end

  def set_tile_taggings
    if parameters[:tile_tag_ids].present?
      tile_tag_ids = parameters[:tile_tag_ids].split(',').map(&:to_i)

      new_tile_tag_ids = tile_tag_ids
      
      if tile.persisted?
        existing_tile_tag_ids = @tile.tile_taggings.map(&:tile_tag_id)
        new_tile_tag_ids = tile_tag_ids - existing_tile_tag_ids                    
      end
      
      #only keep the new and non-removed tile taggings
      associated_tile_taggings = tile.tile_taggings.where(tile_tag_id: tile_tag_ids)
      new_tile_tag_ids.each do |tile_tag_id|
        associated_tile_taggings << tile.tile_taggings.build(tile_tag_id: tile_tag_id)
      end
      tile.tile_taggings = associated_tile_taggings
    else 
      tile.tile_taggings = []
    end      
  end

  def main_objects_all_valid
    if !tile.is_sharable?
      errors.add(:base, 'tile share link must be turned on for public tile')      
    elsif  tile.is_public? && 
        tile.tile_taggings.size < 1 && 
        tile.tile_tags.size < 1

      errors.add(:base, 'at least one tag must exist for public tile')
    end
  end
end