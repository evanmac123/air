module TileBatchHelper
  def tile_batch_size_increment
    case device_type
    when :mobile
      2
    when :tablet
      3
    else
      4
    end
  end
end
