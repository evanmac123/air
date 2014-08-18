class TilesDigestMailDigestPresenter < TilesDigestMailBasePresenter
  def initialize(follow_up_email)
    @follow_up_email = follow_up_email
  end

  def follow_up_email
    @follow_up_email
  end

  def slice_size
    follow_up_email ? 1 : 3
  end
end
