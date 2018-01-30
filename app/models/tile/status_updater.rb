class Tile::StatusUpdater
  def self.call(tile:, new_status: nil, redigest: nil)
    Tile::StatusUpdater.new(tile, new_status, redigest).perform
  end

  attr_reader :tile, :new_status, :redigest

  def initialize(tile, new_status, redigest)
    @tile = tile
    @new_status = new_status
    @redigest = redigest
  end

  def perform
    return unless Tile::STATUS.include?(new_status)
    handle_unarchived
    update_status
    tile.save
  end

  private

    def handle_unarchived
      if redigesting?
        tile.activated_at = Time.current
      end
    end

    def redigesting?
      tile.status == Tile::ARCHIVE && new_status == Tile::ACTIVE && redigest == "true"
    end

    def update_status
      tile.status = new_status
    end
end
