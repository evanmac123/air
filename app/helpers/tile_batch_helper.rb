module TileBatchHelper
  def tile_batch_size
    if first_tile_batch
      2 * tile_batch_size_increment
    else
      base_batch_size + tile_batch_size_increment - (base_batch_size % tile_batch_size_increment)
    end
  end

  def first_tile_batch
    params[:base_batch_size].nil? || params[:base_batch_size].empty?
  end

  def base_batch_size
    base_batch_size = params[:base_batch_size].to_i
  end

  def tile_batch_size_increment
    case device_type
    when :mobile
      2
    when :tablet
      4
    else
      4
    end
  end
end
