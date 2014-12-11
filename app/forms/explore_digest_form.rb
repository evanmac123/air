class ExploreDigestForm
  extend  ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  validate :at_least_one_tile_id
  validate :all_tile_ids_viewable_in_public

  def initialize(params)
    @params = params
  end

  def persisted?
    false
  end

  def tile_ids
    @tile_ids ||= @params[:tile_ids].reject(&:blank?).map(&:to_i).uniq
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

  def all_tile_ids_viewable_in_public
    public_tile_ids = Tile.where(id: tile_ids).viewable_in_public.pluck(:id)
    nonpublic_tile_ids = tile_ids - public_tile_ids

    unless nonpublic_tile_ids.empty?
      errors.add(:base, "following tiles are not public: " + nonpublic_tile_ids.sort.join(', '))
    end
  end

  private

  def reorder_explore_page_tiles!
    Tile.transaction do
      starting_priority = Tile.current_highest_explore_page_priority
      priority = starting_priority + 1

      tile_ids.reverse.each do |tile_id|
        Tile.find(tile_id).update_attributes(explore_page_priority: priority)
        priority += 1
      end
    end
  end
end

class ExploreDigestTestForm < ExploreDigestForm
  def initialize(params, user)
    @params = params
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
