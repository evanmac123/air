class ExploreDigestForm
  extend  ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  validate :at_least_one_tile_id
  validate :explore_tiles?

  attr_accessor :features

  def initialize(params, features = nil)
    @params = params
    @features = sanitize(features) || default_features
  end

  def sanitize(features)
    features.each { |feature, attrs|
      attrs["tile_ids"] = clean_tile_ids(attrs["tile_ids"])

      if attrs["headline"].blank? || attrs["custom_message"].blank? || attrs["tile_ids"].empty?
        attrs = nil
      end
    }

    features.delete_if { |k,v| v.nil? }
  end

  def persisted?
    false
  end

  def tile_ids
    @tile_ids ||= clean_tile_ids(@params[:tile_ids])
  end

  def subject
    @subject ||= @params[:subject]
  end

  def headline
    @headline ||= @params[:headline]
  end

  def custom_message
    @custom_message ||= @params[:custom_message]
  end

  def send_digest!
    reorder_explore_page_tiles!
    TilesDigestMailer.delay.notify_all_explore tile_ids, subject, headline, custom_message
  end

  def self.model_name
    ActiveModel::Name.new(ExploreDigestForm)
  end

  protected

  def at_least_one_tile_id
    if tile_ids.empty?
      errors.add(:base, "at least one tile ID must be present")
    end
  end

  def explore_tiles?
    public_tile_ids = Tile.where(id: tile_ids).explore.pluck(:id)
    nonpublic_tile_ids = tile_ids - public_tile_ids

    unless nonpublic_tile_ids.empty?
      errors.add(:base, "following tiles are not explore tiles: " + nonpublic_tile_ids.sort.join(', '))
    end
  end

  private

  def clean_tile_ids(ids)
    ids.reject(&:blank?).map(&:to_i).uniq
  end

  def reorder_explore_page_tiles!
    Tile.reorder_explore_page_tiles! tile_ids
  end

  def default_features
    {
      1 => {
        tile_ids: [nil] * 4
      }
    }
  end
end

class ExploreDigestTestForm < ExploreDigestForm
  def initialize(params, user, features = nil)
    @params = params
    @features = sanitize(features) || default_features
    @user = user
  end

  def user
    @user
  end

  def send_digest!
    reorder_explore_page_tiles!
    TilesDigestMailer.delay.notify_one_explore(user.id, tile_ids, subject, headline, custom_message)
  end
end

class NullExploreDigestForm < ExploreDigestForm
  def initialize
    @features = default_features
  end

  def subject
    nil
  end

  def headline
    nil
  end

  def custom_message
    nil
  end

  def tile_ids
    [nil] * 4
  end
end
