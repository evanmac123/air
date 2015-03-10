class TilePublicForm
  include ActiveModel::Conversion
  attr_accessor :tile, :parameters

  def initialize(tile, parameters = {})
    @tile = tile
    @parameters = parameters
  end

  def save
    set_tile_public_params
    set_tile_taggings
    save_tile
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

  def is_sharable
    tile.is_sharable?
  end

  def self.model_name
    ActiveModel::Name.new(TilePublicForm)
  end

  def persisted?
    false
  end

  protected

  def save_tile
    Tile.transaction { tile.save(context: :client_admin) }
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

  delegate  :is_public,
            to: :tile
end