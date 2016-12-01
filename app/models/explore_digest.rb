class ExploreDigest < ActiveRecord::Base
  scope :delivered, -> { where(delivered: true) }
  scope :approved, -> { where(approved: true) }
  scope :pending, -> { where(approved: false) }

  def defaults(key)
    rdb[:defaults][key].get
  end

  def set_defaults(key, val)
    rdb[:defaults][key].set(val)
  end

  def features(feature, key)
    rdb[:features][feature][key].get
  end

  def set_tile_ids(feature, tile_ids)
    tile_ids = tile_ids.gsub(/\s+/, "").split(",").select { |id| id.to_i != 0 }
    eligible_tiles = Tile.copyable.where(id: tile_ids).pluck(:id)
    tile_ids = tile_ids.select { |id| eligible_tiles.include?(id.to_i) }
    rdb[:features][feature][:tile_ids].set(tile_ids.join(","))
  end

  def set_features(feature, key, val)
    if key.to_sym == :tile_ids
      self.set_tile_ids(feature, val)
    else
      rdb[:features][feature][key].set(val)
    end
  end

  def feature_count
    rdb[:feature_count].get.to_i
  end

  def feature_count=(val)
    rdb[:feature_count].set(val)
  end

  def post_to_redis(defaults_hash, features_hash)
    self.feature_count = features_hash.length
    post_defaults(defaults_hash) if defaults_hash
    post_features(features_hash) if features_hash

    self.save
  end

  def post_defaults(defaults_hash)
    defaults_hash.each { |key, val|
      set_defaults(key, val)
    }
  end

  def post_features(features_hash)
    features_hash.each { |feature, hash|
      hash.each { |key, val|
        set_features(feature, key, val)
      }
    }
  end

  def deliver_test_digest!(current_user)
    ExploreDigestMailer.notify_one(self, current_user)
  end

  def deliver_digest!
    ExploreDigestMailer.delay.notify_all(self, all_client_admin_ids)
  end

  def get_tiles(feature, tiles = Tile.copyable)
    tile_ids = features(feature, :tile_ids).split(",")
    grouped_tiles = tiles.where(id: tile_ids).group_by(&:id)

    tile_ids.map { |id| grouped_tiles[id.to_i].first }
  end

  def validate
    validate_defaults
    validate_features
  end

  private
    def all_client_admin_ids
      User.client_admin.pluck(:id)
    end

    def validate_features
      current_feature = 1

      feature_count.times do
        feature_keys_for_validation.each { |key|
          if features(current_feature, key).to_s.empty?
            errors.add(:base, "#{key} cannot be empty for feature #{current_feature}")
          end
        }
      end
    end

    def validate_defaults
      default_keys_for_validation.each { |key|
        if defaults(key).to_s.empty?
          errors.add(:base, "#{key} cannot be empty for digest")
        end
      }
    end

    def feature_keys_for_validation
      [:headline, :tile_ids]
    end

    def default_keys_for_validation
      [:subject, :header]
    end
end
