# frozen_string_literal: true

# FIXME this whole form object is completely unnecessary this naive attempt at
# modularization.
class TilePublicForm
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :tile, :params

  def initialize(tile, params = {})
    @tile = tile
    @params = params
    @is_public_initial = is_public
  end

  def save
    set_tile_public_params
    tile.save
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

  private

    def set_tile_public_params
      tile.is_public = params[:is_public] if params[:is_public].present?
    end
end
