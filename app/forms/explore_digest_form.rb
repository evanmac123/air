class ExploreDigestForm
  extend  ActiveModel::Naming
  include ActiveModel::Conversion

  def initialize(params)
    @params = params
  end

  def persisted?
    false
  end

  def tile_ids
    @tile_ids ||= @params[:tile_ids]
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
    TilesDigestMailer.delay.notify_all_explore tile_ids, subject, headline, custom_message
  end

  def self.model_name
    ActiveModel::Name.new(ExploreDigestForm)
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
