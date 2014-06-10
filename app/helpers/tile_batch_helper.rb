module TileBatchHelper
  def tile_batch_size
    if first_tile_batch
      2 * tile_batch_size_increment
    else
      tile_batch_size_increment
    end
  end

  def first_tile_batch
    params[:offset].nil? || params[:offset].empty?
  end

  def tile_batch_size_increment
    case device_type
    when :mobile
      2
    when :tablet
      4
    else
      8
    end
  end
end
