module TileBatchHelper
  def tile_batch_size
    2 * tile_batch_size_increment
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
