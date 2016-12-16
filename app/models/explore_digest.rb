class ExploreDigest < ActiveRecord::Base
  scope :delivered, -> { where(delivered: true) }
  scope :approved, -> { where(approved: true).where(delivered_at: nil) }
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
    eligible_tiles = Tile.explore.where(id: tile_ids).pluck(:id)
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
    ExploreDigestMailer.notify_one(self, current_user).deliver
  end

  def deliver_targeted_digest!(user_ids = @targeted_digest_ids)
    users = User.client_admin.where(id: user_ids)

    ExploreDigestMailer.notify_all(self, users)
    self.update_attributes(delivered: true, delivered_at: Time.now)
  end

  def deliver_digest!
    ExploreDigestMailer.delay.notify_all(self)
    self.update_attributes(delivered: true, delivered_at: Time.now)
  end

  def get_tiles(feature, tiles = Tile.explore)
    tile_ids = features(feature, :tile_ids).split(",")
    grouped_tiles = tiles.where(id: tile_ids).group_by(&:id)

    tile_ids.map { |id| grouped_tiles[id.to_i].first }
  end

  def validate(targeted_digest)
    validate_targeted_digest(targeted_digest)
    validate_defaults
    validate_features
  end

  private
    def validate_features
      current_feature = 1

      feature_count.times do
        feature_keys_for_validation.each { |key|
          if features(current_feature, key).to_s.empty?
            errors.add(:base, "#{key} is invalid for feature #{current_feature}")
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

    def validate_targeted_digest(targeted_digest)
      if targeted_digest[:send] == "true"
        @targeted_digest_ids = targeted_digest[:users].gsub(/\s+/, "").split(",").select { |id| id.to_i != 0 }

        if @targeted_digest_ids.empty? || User.client_admin.where(id: @targeted_digest_ids).length != @targeted_digest_ids.length
          errors.add(:base, "Some of your targeted users are not client admin")
        end
      end
    end

    def feature_keys_for_validation
      [:headline, :tile_ids]
    end

    def default_keys_for_validation
      []
    end
end
