module TileBatchHelper
  def tile_batch_size
    case device_type
    when :mobile
      4
    when :tablet
      4
    else
      16
    end
  end

  def first_tile_batch
    params[:offset].nil? || params[:offset].empty?
  end

  def tile_row_size # helps us decide how many placeholder div's to put in
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
